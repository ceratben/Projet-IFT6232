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

;; Transform source->source must return something
(define (const-prop ast)
  (match ast
	 ; (define var const)
	 ((define ,var ,expr) 
	  (if (constant? ,expr) 
	      (begin (propagate ,var ,expr) ast)
	      `(define ,var ,@(const-prop ,expr))))

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

	 ;list
	 ;symbol
	 ((,expr)
	  (if (list? ,expr)
	      (map const-prop ,expr)
	      (let (i (const-lookup ,expr const-list-name 0)) 
		(if i
		    (list-ref const-list-val i)
		    ,expr))
	      ))
	 ;else
	 (else ast)
))


