(begin
  (define (list . args)
    (listAux args)
    )

  (define (listAux lst)
    (if (null? lst)
	'()
	(cons (car lst) (listAux (cdr lst)))
	)
    )

  (define (string->list arg)
    (begin
      (let ((res (list)))
	(begin
	  (let loop ((n 0))
	    (if (< n (string-length arg))
		(begin
		  (set! res (cons (string-ref arg n) res))
		  (loop (+ n 1))
		  )
		)
	    )
	  (reverse res)
	  )
	)
      )
    )
  
  (define-macro (list->string lst)
    `(string ,@(cdr lst))
    )
  
  (define (map f lst)
    (if (not (pair? lst))
	(list)
	(cons (f (car lst))
	      (map f (cdr lst))
	      )
	)
    )
  
  (define (append lst1 lst2)
    (let ((l1 (reverse lst1)))
      (let  ((res lst2))
	(begin
	  (let loop ((n 0))
	    (if (< n (length l1))
		(begin
		  (set! res (cons (list-ref l1 n) res))
		  (loop (+ n 1))
		  )
		)
	    )
	  res
	  )
	)
      )
    )

  (define (reverse lst)
    (let ((res (list)))
      (begin
	(let loop ((n 0))
	  (if (< n (length lst))
	      (begin
		(set! res (cons (list-ref lst n) res))
		(loop (+ n 1))
		)
	      )
	  )
	res
	)
      )
    )

  (define (list-ref lst index)
    (let ((res lst))
      (begin
	(let loop ((n index))
	  (if (> n 0)
	      (begin
		(set! res (cdr res))
		(loop (- n 1))
		)
	      )
	  )
	(car res)
	)
      )
    )
  
  (define (string-append s1 s2)
    (let ((aux1 (string->list s1)))
      (let ((aux2 (string->list s2)))
	(list->string (append aux1 aux2))
	)
      )
    )
  
  (define (string-ref s index)
    (let ((aux (string->list s)))
      (list-ref aux index)
      )
    )
)  
  














