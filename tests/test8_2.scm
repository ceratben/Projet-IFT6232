(begin
  (define closure-code (lambda (clo) (car clo)))
  (begin
    (define closure-ref
      (lambda (clo i) (if (= i 0) (car clo) (closure-ref (cdr clo) (- i 1)))))

    (begin
      (((lambda ($clo) ((closure-code $clo) $clo 2))
        (cons (lambda ($this g1) g1) '())))
      #f)))
