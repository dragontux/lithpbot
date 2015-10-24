(define :mut *hooks* '())

(define (local-add-hook action fn xs)
  (cond ((null? xs)
         (list (list action fn)))
        ((eq? (caar xs) action)
         (cons (cons action
                     (cons fn (cdar xs)))
               (cdr xs)))
        (true
          (cons (car xs) (local-add-hook action fn (cdr xs))))))

(define (add-hook! action fn)
  (define *hooks* (local-add-hook action fn *hooks*)))

(define (handle-hook msg)
  (let ((matches (filter (lambda (xs) (eq? (car xs) [irc-field msg :action]))
                         *hooks*)))

    (if (not (null? matches))
      (foreach matches (lambda (funclist)
        (foreach (cdr funclist) (lambda (fn)
          (fn msg)))))
      '())))
