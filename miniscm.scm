#! /usr/bin/env gsi

(include "defmacro.scm")
(include "setop.scm")
(include "freevar.scm")
(include "clo-conv.scm")
(include "alpha-conv.scm")
(include "constant-prop.scm")
(include "stdlib.scm")

;; Plan pour la suite:
;; Refaire les phases d'expansions macro -> alpha-conv etc -> passe globale *-> comp-expr -> gen-code
;; Definir des fermetures au niveau du runtime.

;;; File: "miniscm.scm"

(define env-lookup 
  (lambda (data env pos)
      (if (equal? (car env) data)
	  pos
	  (if (null? (cdr env)) #f
	      (env-lookup data (cdr env) (+ pos 1)))
	  )))

;;; de stack overflow
(define (list-set! l k obj)
  (cond
    ((or (< k 0) (null? l)) #f)
    ((= k 0) (set-car! l obj))
    (else (list-set! (cdr l) (- k 1) obj))))

(define (flatten lst)
  (cond 
    ((null? lst)
      '())
    ((list? (car lst))
      (append (flatten (car lst)) (flatten (cdr lst))))
    (else
      (cons (car lst) (flatten (cdr lst))))))

;;; fold parce que je ne le trouve pas
(define foldl 
  (lambda (f i l)
    (if (null? l) i (foldl f (f i (car l)) (cdr l)))
    ))

;; Conversion des fermetures.

(define (closure-conversion ast) 
  (clo-conversion 
   (assign-conv ast)))

;;; Translation of AST to machine code

(define def-code '())

(define (translate ast)
  (cons 
   (comp-function "_main" ast) 
   def-code))

(define mem-init 
  (list
   "    pushl   %ebp\n"
   "    movl    %esp, %ebp\n"
   "    subl    $8, %esp\n"
   "    call    _mem_init\n"
   "    leave\n"
   ))

(define (hash-symbol s)
  (string-append "_" (list->string 
		      (map (lambda (x) 
			     (if (equal? x #\-) #\_ x)) 
			   (string->list(symbol->string s))))))

(define sym-table '())

(define (comp-function name expr)
  (gen-function name
                (cons mem-init
		      (comp-expr expr 0 '() '()))))

(define (comp-expr expr fs cte rte) ;; fs = frame size
                                    ;; cte = compile time environment
                                    ;; rte = run time environment
  (cond ((number? expr)
         (let ((l-name (gensym)))
			   (begin
				 ;; Creer les blocs assembleurs associés.
				 (let ((code (gen-number expr)))
				   (set! def-code 
					   (cons (gen-global 
						  l-name
						  code )
						 def-code))
				 )
				 l-name
				 )))

	((eq? expr '__void) "") ; Ne rien faire si c'est une terminaison de begin.

	((boolean? expr)
	 ;; Problème avec les begins qui retournent tous #f.
	 ;;(if expr (gen-literal 1) (gen-literal 0)))
	 "")

	;;;a faire
	((string? expr)
	 (let ((tag (gensym)))
	       (begin
		 (set! def-code 
		       (cons (gen-global tag
					 (gen-string expr))
		       def-code))
		 tag)))

	((null? expr) gen-null)
 
	;; Gerer les symboles et TODO list litt.
	((and (list? expr) (= (length expr) 2) (eq? (car expr) 'quote)) 
	 (if (list? (cadr expr))
	     gen-null ; TODO list lit go here
	     (let ((tag (hash-symbol (cadr expr))))
	       (if (member? tag sym-table)
		   (gen-call-global tag)
		   (begin 
		     (set! def-code
			   (cons (gen-global tag 
					     (list "    movl    " tag ", %eax\n"))
				 def-code ))
		     (set! sym-table
			   (cons tag sym-table))
		     (gen-call-global tag)
		     )))))

	;;; Var
        ((symbol? expr)
         (let ((x (env-lookup expr cte 0)))
           (if x
               (let ((index (list-ref rte x)))
		 (if (number? index)
		     (gen-parameter (+ fs index))
		     ;;(if (and (pair? index) (string? (car index))) 
		     (gen-call-global index) )
		     ;;index))
		 )
	       ;;; retourne un litéral?
               (error "undefined variable" expr))))	

	;;; if
	((and (list? expr) (= (length expr) 4) (eq? (car expr) 'if))
	 (let ((c-expr (map (lambda (x) (comp-expr x fs cte rte)) (cdr expr)))) 
	   (gen-if (car c-expr) (cadr c-expr) (caddr c-expr))))

	;;; begin
	((and (list? expr) (eq? (car expr) 'begin))
	 (let loop ((x (cdr expr)))
	   (if (null? (cdr x))
	       (comp-expr (car x) fs cte rte)
	       (cond 

		((and (list? (car x) )
		      (= (length (car x)) 3)
		      (eq? (list-ref (car x) 0) 'define))
		 (begin
		   (set! cte (cte-extend cte (list (cadr (car x)))))
		   ;;; On remplace les - par des _ pour l'étiquette.
		   (let ((name (string-append "_" (list->string 
						   (map (lambda (x) 
							  (if (equal? x #\-) #\_ x)) 
							(string->list(symbol->string(cadr (car x)))))))))
		   (begin 
		     (set! rte (rte-extend rte (list name)))
		     (set! def-code 
			   (cons (gen-global 
				  name
				  (let ((c (comp-expr (list-ref (car x) 2) fs cte rte)))
				    (if (symbol? c)
					(list "    call    " c "\n")
					c))) 
				 def-code))
		   (loop (cdr x)))
		   )))

		((and (list? (car x) )
		      (= (length (car x)) 3)
		      (eq? (list-ref (car x) 0) 'set!))
		 (begin
		   (gen-set (list-ref (car x) 1) (comp-expr (list-ref (car x) 2) fs cte rte))
		   (loop (cdr x))))
		
		(else (list (comp-expr (car x) fs cte rte) (loop (cdr x) )))
		))))

	;;; let to change
        ((and (list? expr)
              (= (length expr) 3)
              (eq? (list-ref expr 0) 'let))
         (let ((binding (list-ref (list-ref expr 1) 0)))
           (gen-let (comp-expr (list-ref binding 1)
                               fs
                               cte
			       rte)
                    (comp-expr (list-ref expr 2)
                               (+ fs 1)
                               (cons (list-ref binding 0)
                                     cte) 
			       (cons (- (+ fs 1))
                                     rte)))))

	;;; define
	((and (list? expr)
              (= (length expr) 3)
              (eq? (list-ref expr 0) 'define))
	 "")

	((and (list? expr)
              (= (length expr) 3)
              (eq? (list-ref expr 0) 'define-macro))
         
	 ""
	)	

	;;; lambda
        ((and (list? expr)
              (= (length expr) 3)
              (eq? (list-ref expr 0) 'lambda))
	 (let ((arg (reverse (list-ref expr 1))) (l-name (gensym)))
	   (begin
	   ;;; push les args dans env
	     (let loop ((n 1))
	       (and (<= n (length arg))
		   (begin
		     (set! cte (append (cons (list-ref arg (- n 1)) '()) cte))
 		     (set! rte (append (cons  (- (+ fs n)) '()) rte))
		     (loop (+ n 1)))
		   ))
	     ;; Creer les blocs assembleurs associés.
	     (let ((code (comp-expr (caddr expr) fs cte rte)))
	       (begin 
		 (set! def-code 
			   (cons (gen-global 
				  l-name
				  code )
				 def-code))
		 (gen-lambda l-name)))
	     )))

	((and (list? expr)
              (= (length expr) 2)
              (eq? (list-ref expr 0) 'car))
	 (gen-car (comp-expr (cadr expr) fs cte rte)))

	((and (list? expr)
              (= (length expr) 2)
              (eq? (list-ref expr 0) 'cdr))
	 (gen-cdr (comp-expr (cadr expr) fs cte rte)))
	
	((and (list? expr)
              (= (length expr) 3)
              (eq? (list-ref expr 0) 'cons))
	 (gen-cons (comp-expr (cadr expr) fs cte rte) (comp-expr (caddr expr) fs cte rte)))

	;; Equal, eq and =
	((and (list? expr)
              (= (length expr) 3)
              (or (eq? (list-ref expr 0) 'eq?) (eq? (list-ref expr 0) '=)))
	 (gen-eq
	  (comp-expr (list-ref expr 1) fs cte rte)
	  (comp-expr (list-ref expr 2) fs cte rte)
	  (if (eq? (list-ref expr 0) 'eq?) "_is_eq" "_is_int_eq")
	  ))

	 ;; Bin op.
        ((and (list? expr)
              (= (length expr) 3)
              (member (list-ref expr 0) '(+ - * /)))
         (gen-bin-op
          (case (list-ref expr 0)
            ((+) "add")
            ((-) "sub")
            ((*) "imul")
            ((/) "idiv"))
          (comp-expr (list-ref expr 2) fs cte rte)
          (comp-expr (list-ref expr 1) (+ fs 1) cte rte)))

	;; Call
	((list? expr)
	 (let ((data (map (lambda (x) (comp-expr x (+ fs (length (cdr expr))) cte rte)) expr))) 
	 (gen-call  (car data) (cdr data))))

        (else
         (error "comp-expr cannot handle expression"))))

;;; Code generation for x86-32 using GNU as syntax

(define gen list)

(define gen-externs 
  ".globl EXTERN(start)\n";".extern    _mem_init\n"
   )

(define (gen-function name code)
  (gen ;gen-externs
       "    .text\n"
       ".globl " name "\n"
       name ":\n"
       code
       "    ret\n"))

(define (gen-string text) (gen-string-list (map char->integer (string->list text))))
(define (gen-string-list list)
  (if (null? list)
      gen-null
      (gen-C-bin (car list) (gen-list (cdr list)) "_cons_string")
      ))

(define (gen-list list) 
  (if (null? list)
      gen-null
      (gen-cons (car list) (gen-list (cdr list)))
   ))

(define (gen-global name code)
  (gen "\n" name ":\n" code "    ret\n" ))

(define (gen-call-global name)
  (gen "    call    " name "\n"))

(define (gen-if c t f)
	(let ((sym-else (gensym)) (sym-end (gensym)))
		(gen
			c 
			"    jz " sym-else "\n" 
			t 
			"    jmp " sym-end "\n" 
			sym-else ":\n" 
			f 
			sym-end ":\n"
		)))
(define (gen-set v x) (gen-eq v x setcar_ptr))
(define (gen-lambda name) name);(gen "    movl " name ", %eax\n")) Changer pour mover le nom dans eax.
(define (gen-call fun args)
	(flatten 
	 (gen (map push-arg args)
	      "    call    " 
	      fun "\n"
	      "    addl $" (* 4 (length args)) ", %esp\n" 
	      )))

(define (push-arg arg)
	(gen (if (symbol? arg)
		 (gen "    movl    " arg " , %eax\n")
		 arg)
	     "    pushl   %eax\n"))

(define (gen-bin-op oper opnd1 opnd2)
  (gen (gen-unary opnd1 "_unbox_fixnum")
       "    pushl   %eax\n"
       (gen-unary opnd2 "_unbox_fixnum")
       "    " oper "l    (%esp), %eax\n"
       "    addl    $4, %esp\n"))

(define (gen-car x) (gen-unary x "_getcar_ptr")) 
(define (gen-cdr x) (gen-unary x "_getcdr_ptr")) 
(define (gen-cons a d) (gen-eq a d "_cons"))
(define gen-null "    call    _null\n")

(define (align count) (gen
       "    pushl    %ebp\n"
       "    movl     %esp, %ebp\n"
       "    subl     $24, %esp\n"))

(define (gen-unary x name) 
  (gen (align 1) (push-arg x) "    call    " name "\n" "    leave \n"))

(define (gen-eq arg1 arg2 name) 
  (gen-C-bin arg1 arg2 name))

(define (gen-C-bin arg1 arg2 name)
  (gen  (align 2)
	(push-arg arg1)
	(push-arg arg2)
	"    call    "name "\n"
	"    leave\n"
       ))

(define (gen-let val body)
  (gen val
       "    pushl   %eax\n"
       body
       "    addl    $4, %esp\n"))

(define (gen-parameter i)
  (gen "    movl    " (* 4 i) "(%esp), %eax\n"))

(define (gen-literal n)
  (gen "    movl    $" n ", %eax\n"))

(define (gen-number n) (gen-unary (gen "    movl $" n ", %eax\n") "_box_fixnum"))

;; Main program:

(define (exec-include expr)
  (match expr
	 ((include ,name) (parse name))
	 ((begin . ,xs) `(begin ,@(map exec-include xs)))
	 (,x x)
	 ))

(define (main source-filename)
  (let ((ast (parse source-filename)))
    (let ((code
	   (translate
	    (const-prop
	     (expand-program
	      (closure-conversion
	       (alpha-conv
		(exec-include
		 (expand-program ast)))))))))
      (with-output-to-file
          (string-append (path-strip-extension source-filename) ".s")
        (lambda ()
          (print code))))))
