(define (exec-include expr)
  (match expr
	 ((include ,name) (parse name))
	 ((begin ,xs) `(begin ,@(map exec-include xs)))
	 (,x x)
	 ))