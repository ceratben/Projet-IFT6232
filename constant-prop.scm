(define const-list-name '())
(define const-list-val '())
(define (propagate name const) 
  (begin 
    (set! const-list-name (cons name const-list-name))
    (set! const-list-val (cons const const-list-val))
)) 
(define (const-lookup name list count)
  (if (null? list)
      #f
      (if (eq? list name)
	  count
	  (const-lookup name (cdr list) (+ count 1)))))

(define (remove-const i) 
  (begin 
    (set! const-list-name
	  (filter 
	   (lambda (x) (let ((ind 0)) 
			 (if (= ind i)
			     #f
			     (and (set! ind (+ 1 ind)) #t))))
	   const-list-name
	   ))
    (set! const-list-val
	  (filter 
	   (lambda (x) (let ((ind 0)) 
			 (if (= ind i)
			     #f
			     (and (set! ind (+ 1 ind)) #t))))
	   const-list-val
	   ))
    ))

;; Transform source->source must return something
(define (const-prop ast)
  (match ast
	 ; (define var const)
	 ((define ,var ,expr) 
	  (if (constant? expr) 
	      (begin (propagate var expr) ast)
	      `(define ,var ,@(const-prop expr))))

	 ; lambda used as let
	 (((lambda ,arg1 ,expr) . ,args )
	  (begin 
	    (map 
	     (lambda (x y) 
	       (if (constant? y) 
		   (propagate x y)
		   #t))
	     ,arg1
	     ,args)
	    `(lambda ,arg1 (const-prop ,expr) ,@(map const-prop ,args))
	    ))

	 ;set!
	 ((set! ,var ,expr)
	  (let ((i (const-lookup var const-list-name 0)))
	    (if i
		(begin
		  (remove-const i)
		  `(set! ,var ,@(const-prop expr)))
		`(set! ,var ,@(const-prop expr)))))

	 ;list
	 ;symbol
	 ((,expr)
	  (if (list? expr)
	      (map const-prop expr)
	      (let ((i (const-lookup expr const-list-name 0))) 
		(if i
		    (list-ref const-list-val i)
		    expr))
	      ))
	 ;else
	 (else ast)
))


