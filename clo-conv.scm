(define (constant? c)
  (match c
    ((quote ,x)
     #t)
    (,x
     (or (number? x)
         (string? x)
         (boolean? x)
         (char? x)))))

(define primitives '(+ - * / eq? = < > <= >=
                     null? pair? cons car cdr set-car! set-cdr! display begin))

(define (primitive? op)
  (and (symbol? op)
       (memq op primitives)))

;; Assignment-conversion.
(define (assign-conv expr)
  (let ((globals (fv expr)))
    (assignc expr (difference (mv expr) globals))))

(define (assignc expr mut-vars)

  (define (ac e)
    (assignc e mut-vars))

  (define (mutable? v)
    (memq v mut-vars))

  (match expr

    (,c when (constant? c)
     expr)

    ((quote ,x)
     expr)

    (,v when (symbol? v)
     (if (mutable? v) `(car ,v) v))

    ((set! ,v ,E1)
     (if (mutable? v)
         `(set-car! ,v ,(ac E1))
         `(set! ,v ,(ac E1))))

    ((define ,v ,E1)
     `(define ,v ,(ac E1)))

    ((lambda ,params ,E)
     (let* ((mut-params
             (map (lambda (p) (cons p (gensym)))
                  (keep mutable? params)))
            (params2
             (map (lambda (p)
                    (if (mutable? p)
                        (cdr (assq p mut-params))
                        p))
                  params)))
       `(lambda ,params2
          ,(if (null? mut-params)
               (ac E)
               `(let ,(map (lambda (x) `(,(car x) (cons ,(cdr x) '())))
                           mut-params)
                   ,(ac E))))))

    ((let ,bindings ,E)
     (let* ((vars
             (map car bindings))
            (mut-vars
             (map (lambda (v) (cons v (gensym)))
                  (keep mutable? vars)))
            (vars2
             (map (lambda (v)
                    (if (mutable? v)
                        (cdr (assq v mut-vars))
                        v))
                  vars)))
       `(let ,(map (lambda (v e) `(,v ,(ac (cadr e))))
                   vars2
                   bindings)
          ,(if (null? mut-vars)
               (ac E)
               `(let ,(map (lambda (x) `(,(car x) (cons ,(cdr x) '())))
                           mut-vars)
                   ,(ac E))))))

    ((if ,E1 ,E2)
     `(if ,(ac E1) ,(ac E2)))
    ((if ,E1 ,E2 ,E3)
     `(if ,(ac E1) ,(ac E2) ,(ac E3)))

    ((,E0 . ,Es)
     `(,(if (primitive? E0) E0 (ac E0))
       ,@(map ac Es)))

    (,_
     (error "unknown expression" expr))))

;;; Closure Conversion

(define (clo-conversion ast)
   (append 
    '(begin
       (define make-closure list)
       (define closure-code (lambda (clo) (car clo)))
       (define closure-ref (lambda (clo i) (if (= i 0) (car clo) (closure-ref (cdr clo) (- i 1)))))
       )
    (cons (map closure-conv (list ast)) '())))

;; Closure-conversion.

(define (closure-conv expr)
  (let ((globals (fv expr)))
    (closurec expr '() globals)))

(define (closurec expr cenv globals)

  (define (cc e)
    (closurec e cenv globals))

  (define (pos id)
    (let ((x (memq id cenv)))
      (and x
           (- (length cenv)
              (length x)))))

  (match expr

    (,c when (constant? c)
     expr)

    ((quote ,x)
     expr)

    (,v when (symbol? v)
     (let ((p (pos v)))
       (if p
           `(closure-ref $this ,p)
           v)))

    ((set! ,v ,E1)
     `(set! ,v ,(cc E1)))

    ((define ,v ,E1)
     `(define ,v ,(cc E1)))

    ((lambda ,params ,E)
     (let ((new-cenv (difference (fv expr) globals)))
       `(make-closure
         (lambda ($this ,@params)
           ,(closurec E new-cenv globals))
         ,@(map cc new-cenv))))

    ;;((let ,bindings ,E)
    ;; `(let ,(map (lambda (b) `(,(car b) ,(cc (cadr b)))) bindings)
    ;;    ,(cc E)))

    ((if ,E1 ,E2)
     `(if ,(cc E1) ,(cc E2)))
    ((if ,E1 ,E2 ,E3)
     `(if ,(cc E1) ,(cc E2) ,(cc E3)))

    ((,E0 . ,Es)
     (if (primitive? E0)
         `(,E0 ,@(map cc Es))
         `((lambda
	       ($clo)
	     ((closure-code $clo)
	      $clo
	      ,@(map cc Es))) ,(cc E0))))

    (,_
     (error "unknown expression" expr))))
