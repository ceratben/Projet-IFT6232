;;; Match Utiliser le code de la demo.

;; (define-macro (match sujet . clauses)
;;   (define (if-equal? var gab oui non)
;;     (cond ((and (pair? gab)
;; 		(eq? (car gab) 'unquote)
;; 		(pair? (cdr gab))
;; 		(null? (cddr gab)))
;; 	   `(let ((,(cadr gab) ,var))
;; 	      ,oui))
;; 	  ((null? gab)
;; 	   `(if (null? ,var) ,oui ,non))
;; 	  ((symbol? gab)
;; 	   `(if (eq? ,var ',gab) ,oui ,non))
;; 	  ((or (boolean? gab)
;; 	       (char? gab))
;; 	   `(if (eq? ,var ,gab) ,oui ,non))
;; 	  ((number? gab)
;; 	   `(if (eqv? ,var ,gab) ,oui ,non))
;; 	  ((pair? gab)
;; 	   (let ((carvar (gensym))
;; 		 (cdrvar (gensym)))
;; 	     `(if (pair? ,var)
;; 		  (let ((,carvar (car ,var)))
;; 		    ,(if-equal? carvar (car gab)
;; 				`(let ((,cdrvar (cdr ,var)))
;; 				   ,(if-equal? cdrvar (cdr gab) oui non))
;; 				non))
;; 		  ,non)))
;; 	  (else
;; 	   (error "unknown pattern"))))
  
;;   (let* ((var (gensym))
;; 	 (fns (map (lambda (x) (gensym)) clauses))
;; 	 (err (gensym)))
;;     `(let ((,var ,sujet))
;;        ,@(map (lambda (fn1 fn2 clause)
;; 		`(define (,fn1)
;; 		   ,(if-equal? var
;; 			       (car clause)
;; 			       (if (and (eq? (cadr clause) 'when)
;; 					(pair? (cddr clause)))
;; 				   `(if ,(caddr clause) ,(cadddr clause) (,fn2))
;;                                      (cadr clause))
;;                                  `(,fn2))))
;;                 fns
;;                 (append (cdr fns) (list err))
;;                 clauses)
;;          (define (,err) (error "match failed"))
;;          (,(car fns)))))

;; (define gensym ;; une version de gensym utile pour le deboguage
;;   (let ((count 0))
;;       (lambda ()
;;         (set! count (+ count 1))
;;         (string->symbol (string-append "g" (number->string count))))))

;; ;;;;;

;; (define gcte '(argc))
;; (define grte '(1))
;; (define macro-list '())

;;; Executing define: A enlever.

;; (define defining 
;;   (lambda (expr)
;;     (cond
;; 	   ((and (list? expr) (eq? (car expr) 'begin)) (map defining (cdr expr)))
;; 	   ((and (list? expr)
;;               (= (length expr) 3)
;;               (eq? (list-ref expr 0) 'define))
;; 	    (begin 
;; 	      (set! gcte (append (cons (list-ref expr 1) '()) gcte)) 
;; 	      (set! grte (append (cons (comp-expr (list-ref expr 2) 0 gcte grte) '())grte))
;; 	      (print grte)))
;; 	   ;; ((and (list? expr)
;;            ;;    (= (length expr) 3)
;;            ;;    (eq? (list-ref expr 0) 'define-macro)) 
;; 	   ;;  (let ((sig (list-ref expr 1)) (body (list-ref expr 2)))
;; 	   ;;    (set! macro-list (cons (cons sig body) macro-list))))
;; 	   )))

;; (define macro-lookup
;;   (lambda (x l)
;;       (and (pair? l) 
;; 	   (if (eq? x (caaar l))
;; 	       (car macro-list)
;; 	       (macro-lookup x (cdr l)))
;; 	   )))

;; (define expand-macro
;;   (lambda (expr macr)
;;       (let* ((fpara (map list (cdr expr) (cdar macr))) (body (cdr macr)) 
;; 	    (f (lambda (a) 
;; 		 (let ((x (assoc a fpara)))
;; 		   (if x (cdr x) a)))))
;; 	(if (list? body)
;; 	      (map f body)
;; 	      (f body))
;; 	  )))

;; (define apply-macro 
;;   (lambda (ast)
;;       (if (pair? ast) 
;; 	   (let ((x (macro-lookup (car ast) macro-list)) (params (map apply-macro (cdr ast))))
;; 	     (if x
;; 		 (let ((newTok (eval (expand-macro (cons (car ast) params) x))))
;; 		   (begin 
;; 		     (defining newTok)
;; 		     (apply-macro newTok)
;; 		     ))
;; 		 (cons (car ast) params))
;; 	     )
;; 	   ast)))
