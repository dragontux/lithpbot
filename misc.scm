; Miscellanious utility functions
; all of these should probably be moved into proper modules
; at some point.
;
(define foreach)
(define foreach
  (lambda (xs f)
    (if (null? xs)
      '()
      (begin
        (f (car xs))
        (foreach (cdr xs) f)))))


(define until
  (lambda (token f arg)
    (define c (f arg))
    (if (eq? c token)
      '()
      (cons c (until token f arg)))))

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

(define equal?
  (lambda (xs ys)
    (if (list? xs)
      (or (and (null? xs) (null? ys))
        (and (and (and
          (not (null? xs))
          (not (null? ys)))
          (equal? (car xs) (car ys)))
          (equal? (cdr xs) (cdr ys))))
     else
      (eq? xs ys))))

(define list-replace
  (lambda (xs old new)
    (if (null? xs)
      '()
    (if (eq? (car xs) old)
      (cons new (list-replace (cdr xs) old new))
     else
      (cons (car xs) (list-replace (cdr xs) old new))))))

(define delim
  (lambda (xs token)
    (if (null? xs)
      '()
    (if (eq? (car xs) token)
      '()
      (cons (car xs) (delim (cdr xs) token))))))

(define after
  (lambda (xs token)
    (if (null? xs)
      '()
    (if (eq? (car xs) token)
      (cdr xs)
     else
      (after (cdr xs) token)))))

(define list-split
  (lambda (xs token)
    (if (null? xs)
      '()
      (cons (delim xs token) (list-split (after xs token) token)))))

(define string-split
  (lambda (str token)
    (map list->string (list-split (str-iter str) token))))

(define list-ref
  (lambda (xs n)
    (if (null? xs)
      '()
    (if (eq? n 0)
      (car xs)
      (list-ref (cdr xs) (- n 1))))))

(define cadr
  (lambda (xs)
    (car (cdr xs))))

(define cddr
  (lambda (xs)
    (cdr (cdr xs))))

(define ident
  (lambda (x)
    x))

(define loop-iter
  (lambda ()
    (define cont? #t)

    (hashmap :iter (iterator ident
                       (lambda (cur n)
                         (cont? cur '())))

             :stop (lambda ()
                     (define cont? #f)))))

(define infix (lambda (a op b) (op a b)))

(define first (lambda (xs) (list-ref xs 0)))
(define second (lambda (xs) (list-ref xs 0)))
