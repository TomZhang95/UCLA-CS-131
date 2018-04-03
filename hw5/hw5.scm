;(null-ld? obj)
;Return #t if obj is an empty listdiff, #f otherwise.
(define (null-ld? obj)
	(cond
		((null? obj) #f)
		((not(pair? obj)) #f)
		(else (eq? (car obj) (cdr obj)))
	)
)


;(listdiff? obj)
;Return #t if obj is a listdiff, #f otherwise
(define (listdiff? obj)
	(cond
		((null-ld? obj) #t)
		((null? obj) #f)
		((not (pair? obj)) #f)
		((not (pair? (car obj))) #f)
		;Iteratively compare the rest of the two parts of obj
		(else (listdiff? (cons (cdr (car obj)) (cdr obj))))
	)
)


;(car-ld listdiff)
;Return the first element of listdiff. It is an error if listdiff has no elements. 
;("It is an error" means the implementation can do anything it likes when this happens, 
;and we won't test this case when grading.)
(define (car-ld listdiff)
	(if (and (listdiff? listdiff) (not (null-ld? listdiff)))
		(car (car listdiff))
		(error "Not a listdiff object")
	)
)


;(cdr-ld listdiff)
;Return a listdiff containing all but the first element of listdiff. 
;It is an error if listdiff has no elements.
(define (cdr-ld listdiff)
	(if (and (listdiff? listdiff) (not (null-ld? listdiff)))
		;Get rid of the car-ld by using cons
		(cons (cdr (car listdiff)) (cdr listdiff))
		(error "Not a listdiff object")
	)
)


;(listdiff obj …)
;Return a newly allocated listdiff of its arguments.
(define (listdiff obj . args)
	(cons (cons obj args) '())
)


;(length-ld listdiff)
;Return the length of listdiff.
(define (length-ld listdiff)
	(cond
		((not (listdiff? listdiff)) (error "Not a listdiff."))
		((null-ld? listdiff) 0)
		;(else (+ 1 (length-ld (cons (cdr (car listdiff)) (cdr listdiff)))))
		(else
			;Tail recursion, above is regular recursion
			(let tail-rec ((ld listdiff) (counter 0))
				(if (null-ld? ld)
					counter
					(tail-rec (cons (cdr (car ld)) (cdr ld)) (+ 1 counter))
				)
			)
		)
	)
)


;(append-ld listdiff …)
;Return a listdiff consisting of the elements of the first listdiff followed 
;by the elements of the other listdiffs. The resulting listdiff is always newly 
;allocated, except that it shares structure with the last argument. (Unlike append, 
;the last argument cannot be an arbitrary object; it must be a listdiff.)
(define (append-ld listdiff . others)
	(cond
		((null? others) listdiff)
		(else
			(apply append-ld
				;listdiff = append listdiff to car of first other listdiff
				(cons 
					(append (take (car listdiff) (length-ld listdiff)) (car (car others)))
					(cdr (car others))
				)
				;others = rest of other listdiffs
				(cdr others)
			)
		)
	)
)


;(list-tail-ld listdiff k)
;Return listdiff, except with the first k elements omitted. If k is zero, 
;return listdiff. It is an error if k exceeds the length of listdiff.
(define (list-tail-ld listdiff k)
	(cond
		((= k 0) listdiff)
		((> k (length-ld listdiff)) (error "k exceed length of listdiff"))
		(else
			(list-tail-ld (cons (cdr (car listdiff)) (cdr listdiff)) (- k 1))
		)
	)
)


;(list->listdiff list)
;Return a listdiff that represents the same elements as list.
(define (list->listdiff list)
  	(cond
  		((list? list) (apply listdiff (car list) (cdr list)))
		(else (error "Object not a list"))
	)
)


;(listdiff->list listdiff)
;Return a list that represents the same elements as listdiff.
(define (listdiff->list listdiff)
	(cond
		((listdiff? listdiff) (take (car listdiff) (length-ld listdiff)))
		(else (error "Object not a listdiff"))
	)
)


;(expr-returning listdiff)
;Return a Scheme expression that, when evaluated, will return a copy of listdiff, 
;that is, a listdiff that has the same top-level data structure as listdiff. Your 
;implementation can assume that the argument listdiff contains only booleans, characters, 
;numbers, and symbols.
(define (expr-returning listdiff)
	(cond
		((not (listdiff? listdiff)) (error "Object not a listdiff"))
		(else
			(let ((content (take (car listdiff) (length-ld listdiff))))
				`(cons ',content '())
			)
		)
	)
)

;(define ils (append '(a e i o u) 'y))
;(define d1 (cons ils (cdr (cdr ils))))
;(define d2 (cons ils ils))
;(define d3 (cons ils (append '(a e i o u) 'y)))
;(define d4 (cons '() ils))
;(define d5 0)
;(define d6 (listdiff ils d1 37))
;(define d7 (append-ld d1 d2 d6))
;(define e1 (expr-returning d1))

;(listdiff? d1)                         
;(listdiff? d2)                         
;(listdiff? d3)                         
;(listdiff? d4)                         
;(listdiff? d5)                         
;(listdiff? d6)                         
;(listdiff? d7)                         

;(null-ld? d1)                          
;(null-ld? d2)                          
;(null-ld? d3)                          
;(null-ld? d6)                          

;(car-ld d1)                            
;(car-ld d2)                            
;(car-ld d3)                            
;(car-ld d6)                            

;(length-ld d1)                         
;(length-ld d2)                         
;(length-ld d3)                         
;(length-ld d6)                         
;(length-ld d7)                         

;(define kv1 (cons d1 'a))
;(define kv2 (cons d2 'b))
;(define kv3 (cons d3 'c))
;(define kv4 (cons d1 'd))
;(define d8 (listdiff kv1 kv2 kv3 kv4))
;(define d9 (listdiff kv3 kv4))
;(eq? d8 (list-tail-ld d8 0))           
;(equal? (listdiff->list (list-tail-ld d8 2))
;        (listdiff->list d9))           
;(null-ld? (list-tail-ld d8 4))         
;(list-tail-ld d8 -1)                   
;(list-tail-ld d8 5)                    

;(eq? (car-ld d6) ils)                  
;(eq? (car-ld (cdr-ld d6)) d1)          
;(eqv? (car-ld (cdr-ld (cdr-ld d6))) 37)
;(equal? (listdiff->list d6)
;        (list ils d1 37))              
;(eq? (list-tail (car d6) 3) (cdr d6))  

;(listdiff->list (eval e1))             
;(equal? (listdiff->list (eval e1))
;        (listdiff->list d1))           