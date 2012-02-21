#! /usr/bin/env gsi

;;; File: "miniscm.scm"


;;; Match

(define-macro (match sujet . clauses)
  (define (if-equal? var gab oui non)
    (cond ((and (pair? gab)
		(eq? (car gab) 'unquote)
		(pair? (cdr gab))
		(null? (cddr gab)))
	   `(let ((,(cadr gab) ,var))
	      ,oui))
	  ((null? gab)
	   `(if (null? ,var) ,oui ,non))
	  ((symbol? gab)
	   `(if (eq? ,var ',gab) ,oui ,non))
	  ((or (boolean? gab)
	       (char? gab))
	   `(if (eq? ,var ,gab) ,oui ,non))
	  ((number? gab)
	   `(if (eqv? ,var ,gab) ,oui ,non))
	  ((pair? gab)
	   (let ((carvar (gensym))
		 (cdrvar (gensym)))
	     `(if (pair? ,var)
		  (let ((,carvar (car ,var)))
		    ,(if-equal? carvar (car gab)
				`(let ((,cdrvar (cdr ,var)))
				   ,(if-equal? cdrvar (cdr gab) oui non))
				non))
		  ,non)))
	  (else
	   (error "unknown pattern"))))
  
  (let* ((var (gensym))
	 (fns (map (lambda (x) (gensym)) clauses))
	 (err (gensym)))
    `(let ((,var ,sujet))
       ,@(map (lambda (fn1 fn2 clause)
		`(define (,fn1)
		   ,(if-equal? var
			       (car clause)
			       (if (and (eq? (cadr clause) 'when)
					(pair? (cddr clause)))
				   `(if ,(caddr clause) ,(cadddr clause) (,fn2))
                                     (cadr clause))
                                 `(,fn2))))
                fns
                (append (cdr fns) (list err))
                clauses)
         (define (,err) (error "match failed"))
         (,(car fns)))))

(define gensym ;; une version de gensym utile pour le deboguage
  (let ((count 0))
      (lambda ()
        (set! count (+ count 1))
        (string->symbol (string-append "g" (number->string count))))))

;;;;;

(define gcte '(argc))
(define grte '(1))
(define macro-list '())

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
	   ((and (list? expr)
              (= (length expr) 3)
              (eq? (list-ref expr 0) 'define-macro)) 
	    (let ((sig (list-ref expr 1)) (body (list-ref expr 2)))
	      (set! macro-list (cons (cons sig body) macro-list))))
	   )))

(define macro-lookup
  (lambda (x l)
      (and (pair? l) 
	   (if (eq? x (caaar l))
	       (car macro-list)
	       (macro-lookup x (cdr l)))
	   )))

(define expand-macro
  (lambda (expr macr)
      (let* ((fpara (map list (cdr expr) (cdar macr))) (body (cdr macr)) 
	    (f (lambda (a) 
		 (let ((x (assoc a fpara)))
		   (if x (cdr x) a)))))
	(if (list? body)
	      (map f body)
	      (f body))
	  )))

(define apply-macro 
  (lambda (ast)
      (if (pair? ast) 
	   (let ((x (macro-lookup (car ast) macro-list)) (params (map apply-macro (cdr ast))))
	     (if x
		 (let ((newTok (eval (expand-macro (cons (car ast) params) x))))
		   (begin 
		     (defining newTok)
		     (apply-macro newTok)
		     ))
		 (cons (car ast) params))
	     )
	   ast)))

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

	;;;a faire
	;;;((string? expr)
	 ;;;(begin (pp expr) ""))

	;;; Var
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

	;;; if
	((and (list? expr) (= (length expr) 4) (eq? (car expr) 'begin))
	 (let ((c-expr (map (lambda (x) (comp-expr x fs cte rte)) (cdr expr)))) 
	   (gen-if (cadr c-expr) (caddr c-expr) (cadddr expr))))

	;;; begin à bouclifier.
	((and (list? expr) (eq? (car expr) 'begin))
	 (let ((ret '())) (begin
	   (let loop ((n 1))
	       (and (< n (length expr))
		   (begin
		     (set! ret (append (cons (comp-expr(list-ref expr n) fs cte rte) '()) ret))
		     (loop (+ n 1)))
		   ))) ret))

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
	((and (list? expr)
              (= (length expr) 3)
              (eq? (list-ref expr 0) 'define-macro))
         
	 ""
	)

	;;; set! doesn't work!
	;;; define devrait associer un espace memoire avec malloc.
	((and (list? expr) (= (length expr) 3) (eq? (car expr) 'set!))
	 (let ((i (env-lookup (list-ref expr 1) cte 0)))
	   (if i 
	       (list-set! rte i (comp-expr (list-ref expr 2) fs cte rte)) 
	       (error "Unbound variable" (list-ref expr 1)))
	  ))

	;;; lambda
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

(define (gen-if c t f) "")

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
		  (translate 
		   (apply-macro ast)))))
      (with-output-to-file
          (string-append (path-strip-extension source-filename) ".s")
        (lambda ()
          (print code))))))
