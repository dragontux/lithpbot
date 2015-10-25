(define :mut *commands* '())

(define (handle-command msg)
  (foreach *commands*
     (lambda (cmd)
       (if (infix [first cmd] = [first split])
         ([cadr cmd] msg)
        else
         '()))))

(define (make-command name funcs)
  (list name funcs))

(define (add-command! name funcs)
  (define *commands*
    (cons (make-command name funcs) *commands*)))

(define (remove-command! name)
  (define *commands* (filter (lambda (command)
                               (not (eq? (car command) name)))
                             *commands*)))

(define (load-command! name)
  (let ((filename (concat "commands/" name ".scm")))
    (if (exists? filename)
      (load! filename)
      #f)))

(define (reload-command! name)
  (remove-command! name)
  (load-command! name))
