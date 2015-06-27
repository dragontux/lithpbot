(import! 'lists)

(define bot-manage
  (lambda (msg)
    (define args (list-split (after (assq :message msg) #\ ) #\ ))

    (if (and (eq? (irc-field msg :nick) "trezz")
             (eq? (irc-field msg :host) "the.innernet"))
      (begin
        (if (equal? (car args) (str-iter "join"))
          (irc-join serv (list->string (cadr args)))
        (if (equal? (car args) (str-iter "part"))
          (irc-part serv (list->string (cadr args)))
        (if (equal? (car args) (str-iter "say"))
          (irc-privmsg serv (list->string (cadr args))
                (str-concat (map
                              (lambda (s)
                                (string-append (list->string s) " "))
                              (cddr args))))
         else
          (irc-privmsg serv (irc-replyto msg) "Dunno what that is man")))))
     else
      (irc-privmsg serv (irc-replyto msg) "What, no"))))
