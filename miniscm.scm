#! /usr/bin/env gsi

(include "defmacro.scm")
(include "setop.scm")
(include "freevar.scm")
(include "clo-conv.scm")
(include "alpha-conv.scm")

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
  (cons (comp-function "_main" ast) def-code))

(define (comp-function name expr)
  (gen-function name
                (comp-expr expr 0 gcte grte)))

(define (comp-expr expr fs cte rte) ;; fs = frame size
                                    ;; cte = compile time environment
                                    ;; rte = run time environment
  (cond ((number? expr)
         (gen-literal expr))

	((boolean? expr)
	 ;;(if expr (gen-literal 1) (gen-literal 0)))
	 "")
	;;;a faire
	;;;((string? expr)
	 ;;;(begin (pp expr) ""))

	;;((eq? expr 'list) "")

	((null? expr) (gen-null))


	;; TODO Gerer les symboles et litt.
	((and (list? expr) (= (length expr) 2) (eq? (car expr) 'quote)) 
	 "")

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
		   (let ((name (string-append "_" (list->string 
						   (map (lambda (x) 
							  (if (equal? x #\-) #\_ x)) 
							(string->list(symbol->string(cadr (car x)))))))))
		   (begin 
		     (set! rte (rte-extend rte (list name)))
		     (set! def-code 
			   (cons (gen-global 
				  name
				  (comp-expr (list-ref (car x) 2) fs cte rte)) 
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
	 ;;(begin
	 ;;  (set! gcte (cte-extend gcte (list (cadr expr))))
	 ;;  (set! grte (rte-extend grte (list (comp-expr (caddr expr) fs cte rte))))))

	((and (list? expr)
              (= (length expr) 3)
              (eq? (list-ref expr 0) 'define-macro))
         
	 ""
	)

	

	;;; lambda
        ((and (list? expr)
              (= (length expr) 3)
              (eq? (list-ref expr 0) 'lambda))
	 ;;; do something
	 (let ((arg (list-ref expr 1)))
	   (begin
	   ;;; push les args dans env
	     (let loop ((n 1))
	       (and (<= n (length arg))
		   (begin
		     (set! cte (append (cons (list-ref arg (- n 1)) '()) cte))
 		     (set! rte (append (cons  (- (+ fs n)) '()) rte))
		     (loop (+ n 1)))
		   ))
	     (gen-lambda rte (comp-expr (caddr expr) fs cte rte))
	     ;;(comp-expr (list-ref expr 2) fs cte rte)
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

	


	;;; call updater le fs graduellement.
	((list? expr)
	 (let ((data (map (lambda (x) (comp-expr x (+ fs (length (cdr expr))) cte rte)) expr))) 
	 (gen-call  (car data) (cdr data))))

        (else
         (error "comp-expr cannot handle expression"))))

;;; Code generation for x86-32 using GNU as syntax

(define gen list)

(define (gen-function name code)
  (gen "    .text\n"
       ".globl " name "\n"
       name ":\n"
       code
       "    ret\n"))

(define (gen-global name code)
  (gen "\n" name ":\n" code "    ret\n" ))

(define (gen-call-global name)
  (gen "    CALL    " name "\n"))

(define (gen-if c t f) "")
(define (gen-set v x) "")
(define (gen-lambda args body) "")           ;;; to implement
(define (gen-call fun args)
;;	(begin
;;		(display "longueur args = ")
;;		(display (length args))
;;		(display "\n")
;;		(display "fun :")
;;		(pp fun)
;;	)
	(gen (map push-arg args)
		fun
		"    addl $" (* 4 (length args)) ", %esp\n"
	))              ;;; to implement
(define (push-arg arg)
	(gen arg
		"    pushl   %eax\n"))


(define (gen-bin-op oper opnd1 opnd2)
  (gen opnd1

       ;; This is slow:
       ;; "    addl    $-4, %esp\n"
       ;; "    movl    %eax, (%esp)\n"

       ;; This is faster:
       "    pushl   %eax\n"

       opnd2

       "    " oper "l    (%esp), %eax\n"
       "    addl    $4, %esp\n"))

(define (gen-car x) "") ;; TODO
(define (gen-cdr x) "") ;; TODO
(define (gen-cons a d) "")
(define gen-null "")

(define (gen-let val body)
  (gen val
       "    pushl   %eax\n"
       body
       "    addl    $4, %esp\n"))

(define (gen-parameter i)
  (gen "    movl    " (* 4 i) "(%esp), %eax\n"))

(define (gen-literal n)
  (gen "    movl    $" n ", %eax\n"))

;; Main program:

(define (main source-filename)
  (let ((ast (parse source-filename)))
    (let ((code
	   (translate 
	    (expand-program
	     (closure-conversion
	      (alpha-conv
	       (expand-program ast)))))))
      (with-output-to-file
          (string-append (path-strip-extension source-filename) ".s")
        (lambda ()
          (print code))))))
