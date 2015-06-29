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
            "join" (lambda () ((serv :join) (list->string (cadr args))))
            "part" (lambda () ((serv :part) (list->string (cadr args))))
            "quit" (lambda () ((serv :quit)
                              (((serv :loop) :stop))))
            "say"  (lambda () ((serv :privmsg) (list->string (cadr args))
                                (str-concat (map
                                  (lambda (s)
                                    (string-append (list->string s) " "))
                                  (cddr args)))))))

        (if (not (eq? (cmds command) #f))
          ((cmds command))
         else
          ((serv :privmsg) (irc-replyto msg) "Dunno what that is man")))
     else
      ((serv :privmsg) (irc-replyto msg) "What, no"))))

