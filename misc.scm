; Miscellanious utility functions
; all of these should probably be moved into proper modules
; at some point.
;
(define (until token f arg)
  (define c (f arg))
  (if (eq? c token)
    '()
    (cons c (until token f arg))))

; todo: move to 'strings module
(define str-iter
  (lambda (str)
    (iterator
      (lambda (n) (string-ref str n))
      (string-length str))))

; todo: move this to dedicated 'sockets module
(define tcp-writestr
  (lambda (sock str)
    (foreach (str-iter str)
      (lambda (c)
        (tcp-putchar sock c)))))

(define (equal? xs ys)
    (if (list? xs)
      (or (and (null? xs) (null? ys))
        (and (and (and
          (not (null? xs))
          (not (null? ys)))
          (equal? (car xs) (car ys)))
          (equal? (cdr xs) (cdr ys))))
     else
      (eq? xs ys)))

(define string-split
  (lambda (str token)
    (map list->string (list-split (str-iter str) token))))

(define ident
  (lambda (x)
    x))

(define loop-iter
  (lambda ()
    (define :mut cont? #t)

    (hashmap :iter (iterator ident
                       (lambda (cur n)
                         (cont? cur '())))

             :stop (lambda ()
                     (define cont? #f)))))

(define infix (lambda (a op b) (op a b)))

(define first (lambda (xs) (list-ref xs 0)))
(define second (lambda (xs) (list-ref xs 0)))

(define :mut seed 2252)

(define random (lambda ()
    (define seed (* (+ seed 1) 33))
    seed))

(define random_int (lambda (range)
    (modulo (random) range)))

(define random_choice (lambda (xs)
    (list-ref xs (random_int (length xs)))))
