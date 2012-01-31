#! /usr/bin/env gsi

;;; File: "miniscm.scm"

;;; Translation of AST to machine code

(define (translate ast)
  (comp-function "_main" ast))

(define (comp-function name expr)
  (gen-function name
                (comp-expr expr 0 '((argc . 1)))))

(define (comp-expr expr fs cte) ;; fs = frame size
                                ;; cte = compile time environment

  (cond ((number? expr)
         (gen-literal expr))

        ((symbol? expr)
         (let ((x (assoc expr cte)))
           (if x
               (let ((index (cdr x)))
                 (gen-parameter (+ fs index)))
               (error "undefined variable" expr))))

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
