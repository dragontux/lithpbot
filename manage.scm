(import! 'lists)

(define bot-manage
  (lambda (msg)
    (define args (list-split (after (msg :message) #\ ) #\ ))
    (define command (list->string (car args)))

    (if (and (eq? (irc-field msg :nick) "trezz")
             (eq? (irc-field msg :host) "the.innernet"))
      (begin
        (define cmds
          (hashmap
            "join" (lambda () (irc-join serv (list->string (cadr args))))
            "part" (lambda () (irc-part serv (list->string (cadr args))))
            "quit" (lambda () (irc-quit serv))
            "say"  (lambda () (irc-privmsg serv (list->string (cadr args))
                                (str-concat (map
                                  (lambda (s)
                                    (string-append (list->string s) " "))
                                  (cddr args)))))))

        (if (not (eq? (cmds command) #f))
          ((cmds command))
         else
          (irc-privmsg serv (irc-replyto msg) "Dunno what that is man")))
     else
      (irc-privmsg serv (irc-replyto msg) "What, no"))))

