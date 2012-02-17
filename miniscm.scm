#! /usr/bin/env gsi

;;; File: "miniscm.scm"

(define-macro (match sujet . clauses) 
  (define (conditions exp gab) (cond ((null? gab) 
				      (list `(null? ,exp))) 
				     ((symbol? gab) 
				      (list `(eq? ,exp ’,gab))) 
				     ((number? gab) 
				      (list `(eqv? ,exp ,gab))) 
				     ((pair? gab) 
				      (append (list `(pair? ,exp)) 
					      (conditions `(car ,exp) (car gab)) 
					      (conditions `(cdr ,exp) (cdr gab)))) 
				     (else 
				      (error "unknown pattern")))) 
  (define (if-equal? var gab oui non) 
    (cond ((and (pair? gab) 
		(eq? (car gab) `unquote) 
		(pair? (cdr gab)) 
		(null? (cddr gab))) 
	   `(let ((,(cadr gab) ,var)) 
	      ,oui)) 
	  ((null? gab) 
	   `(if (null? ,var) ,oui ,non)))) 
    (define (gen var clauses) 
    (if (pair? clauses) 
	(let ((clause (car clauses))) 
	  (if-equal? var 
		     (car clause) 
		     (cadr clause) 
		     (gen var (cdr clauses)))) 
	`(error "match failed"))) 
  (let ((var (gensym))) 
    `(let ((,var ,sujet)) 
       ,(gen var clauses))))


(define gcte '(argc))
(define grte '(1))

(define env-lookup 
  (lambda (data env pos)
      (if (equal? (car env) data)
	  pos
	  (if (null? (cdr env)) #f
	      (env-lookup data (cdr env) (+ pos 1)))
	  )))

;;; Executing define:

(define defining 
  (lambda (expr)
    (cond
	   ((and (list? expr) (eq? (car expr) 'begin)) (map defining (cdr expr)))
	   ((and (list? expr)
              (= (length expr) 3)
              (eq? (list-ref expr 0) 'define))
	    (begin 
	      (set! gcte (append (cons (list-ref expr 1) '()) gcte)) 
	      (set! grte (append (cons (comp-expr (list-ref expr 2) 0 gcte grte) '())grte))
	      (print grte)))
	   )))


;;; Translation of AST to machine code

(define (translate ast)
  (comp-function "_main" ast))

(define (comp-function name expr)
  (gen-function name
                (comp-expr expr 0 gcte grte)))

(define (comp-expr expr fs cte rte) ;; fs = frame size
                                ;; cte = compile time environment

  (cond ((number? expr)
         (gen-literal expr))

	((string? expr)
	 (begin (pp expr) '()))

	;;; A changer pour liste separee.
        ((symbol? expr)
         (let ((x (env-lookup expr cte 0)))
           (if x
               (let ((index (list-ref rte x)))
		 (if (number? index)
		     (gen-parameter (+ fs index))
		     index)
		 )
	       ;;; retourne un litéral?
               (error "undefined variable" expr))))	
	
	;;; begin: Utilise env+cte au lieu de cte pour inclure les definitions precedentes dans la seq.
	((and (list? expr) (eq? (car expr) 'begin))
	 (if (= (length expr) 2)
	     (comp-expr (cadr expr) fs cte rte)
	     (cons 
	       (comp-expr (cadr expr) fs cte rte)
	       (comp-expr (cons 'begin (cddr expr)) fs cte rte))
	  ))

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
         
	 ""
	)

	;;; set!
	((and (list? expr) (= (length expr) 3) (eq? (car expr) 'set!))
	 '())

	;;; lambda to patch env
        ((and (list? expr)
              (= (length expr) 3)
              (eq? (list-ref expr 0) 'lambda))
	 ;;; do something
	 (let ((arg (list-ref expr 1)))
	   (begin
	   ;;; push les args dans cte
	     (let loop ((n 1))
	       (and (<= n (length arg))
		   (begin
		     (set! cte (append (cons (list-ref arg (- n 1)) '()) cte))
 		     (set! rte (append (cons (+ fs n) '()) rte))
		     (loop (+ n 1)))
		   ))
	     (comp-expr (list-ref expr 2) fs cte rte))))

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

	;;; call
	((list? expr)
	 (let ((data (map (lambda (x) (comp-expr x fs cte))))) 
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

(define (gen-lambda args body) "")           ;;; to implement
(define (gen-call fun args) "")              ;;; to implement

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
    (let ((code (begin 
		  (defining ast)
		  (translate ast))))
      (with-output-to-file
          (string-append (path-strip-extension source-filename) ".s")
        (lambda ()
          (print code))))))
