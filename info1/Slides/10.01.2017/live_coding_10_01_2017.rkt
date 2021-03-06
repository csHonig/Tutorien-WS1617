;; Die ersten drei Zeilen dieser Datei wurden von DrRacket eingefügt. Sie enthalten Metadaten
;; über die Sprachebene dieser Datei in einer Form, die DrRacket verarbeiten kann.
#reader(lib "DMdA-advanced-reader.ss" "deinprogramm")((modname live_coding) (read-case-sensitive #f) (teachpacks ()) (deinprogramm-settings #(#f write repeating-decimal #t #t none datum #f ())))
; Prelude
(: curry ((%a %b -> %c) -> (%a -> (%b -> %c))))
(define curry
  (lambda (f)
    (lambda (x)
      (lambda (y)
        (f x y)))))

(: filter ((%a -> boolean) (list-of %a) -> (list-of %a)))
(define filter
  (lambda (p? xs)
    (cond ((empty? xs) empty)
          ((pair? xs)  (if (p? (first xs)) 
                           (make-pair (first xs) (filter p? (rest xs)))
                           (filter p? (rest xs)))))))

; Promise, ein Wert des Vertrags t zu liefern (0-stellig Prozedur)
(define promise
  (lambda (t)
    (signature (-> t))))

; Erzwungene Auswertung
(: force ((promise %a) -> %a))
(define force
  (lambda (p)
    (p)))

; Polymorphe Paare (isomorph zu `pair')
(: make-cons (%a %b -> (cons-of %a %b)))
(: head ((cons-of %a %b) -> %a))
(: tail ((cons-of %a %b) -> %b))
(define-record-procedures-parametric cons cons-of
  make-cons 
  cons?
  (head
   tail))

; Ein Stream besteht aus
; - einem ersten Element (head)
; - einem Promise, den Rest des Streams generieren zu können (tail)
(define stream-of
  (lambda (t)
    (signature (cons-of t (promise (stream-of t))))))

; Extract the first n elements from stream to list
(define stream-take
    (lambda (n str)
      (if (= n 0)
          empty
          (make-pair (head str) 
                     (stream-take (- n 1) (force (tail str)))))))



; ---------------------------
; Stream to get all numbers from 20

(: from (number -> (stream-of number)))
(define from
  (lambda (n)
    (make-cons n (lambda () (from (+ n 1))))))

; Smalles positive number that is evenly divisible by all of the numbers from 1 to 20
(: evenly-divisible (natural -> number))
(check-expect (evenly-divisible 10) 2520)
(define evenly-divisible
  (lambda (n)
    (let
        ((to-be-divided-list (stream-take (- n 1) (from 2))))
      (letrec
          ((worker
            (lambda (acc)
              (if (= (fold 0 +
                        (map ((curry modulo) acc) to-be-divided-list)) 0)
                  acc
                  (worker (+ n acc))))))
        (worker n)))))

