#! /usr/bin/env gsi

;;; File: "miniscm.scm"

;;; Translation of AST to machine code
(define env '((argc . 1)))

(define (translate ast)
  (comp-function "_main" ast))

(define (comp-function name expr)
  (gen-function name
                (comp-expr expr 0 env)))

(define (comp-expr expr fs cte) ;; fs = frame size
                                ;; cte = compile time environment

  (cond ((number? expr)
         (gen-literal expr))

	((string? expr)
	 (begin (pp expr) '()))

        ((symbol? expr)
         (let ((x (assoc expr cte)))
           (if x
               (let ((index (cdr x)))
		 (if (number? index)
		     (gen-parameter (+ fs index))
		     index)
		 )
               (error "undefined variable" expr))))

	;;; call
	
	;;; begin: Utilise env+cte au lieu de cte pour inclure les definitions precedentes dans la seq.
	((and (list? expr) (eq? (car expr) 'begin))
	 (if (= (length expr) 2)
	     (comp-expr (cadr expr) fs cte)
	     (cons 
	       (comp-expr (cadr expr) fs (append cte env))
	       (comp-expr (cons 'begin (cddr expr)) fs (append cte env)))
	     
	  ))

	;;; let
        ((and (list? expr)
              (= (length expr) 3)
              (eq? (list-ref expr 0) 'let))
         (let ((binding (list-ref (list-ref expr 1) 0)))
           (gen-let (comp-expr (list-ref binding 1)
                               fs
                               cte)
                    (comp-expr (list-ref expr 2)
                               (+ fs 1)
                               (cons (cons (list-ref binding 0)
                                           (- (+ fs 1)))
                                     cte)))))

	;;; define
	((and (list? expr)
              (= (length expr) 3)
              (eq? (list-ref expr 0) 'define))
         
	      (let ((token (list-ref expr 1)) (bind (list-ref expr 2))) 
	      ;;; cons une paire et l'ajouter dans un dict de def? 
		(begin
		  (set! env (append (cons (cons token (comp-expr bind fs cte)) '()) cte))
	          ;;; pour tester sinon: '()
		  ;;;(pp cte)
		  ;;;(pp (cdr (assoc token cte)))
		  (comp-expr bind fs cte)
	)))


	;;; lambda
        ((and (list? expr)
              (= (length expr) 3)
              (eq? (list-ref expr 0) 'lambda))
	 ;;; do something
        )


        ((and (list? expr)
              (= (length expr) 3)
              (member (list-ref expr 0) '(+ - * /)))
         (gen-bin-op
          (case (list-ref expr 0)
            ((+) "add")
            ((-) "sub")
            ((*) "imul")
            ((/) "idiv"))
          (comp-expr (list-ref expr 2) fs cte)
          (comp-expr (list-ref expr 1) (+ fs 1) cte)))

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
    (let ((code (translate ast)))
      (with-output-to-file
          (string-append (path-strip-extension source-filename) ".s")
        (lambda ()
          (print code))))))
