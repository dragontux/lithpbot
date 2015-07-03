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
            "join" (lambda () ((server :join) (list->string (cadr args))))
            "part" (lambda () ((server :part) (list->string (cadr args))))
            "quit" (lambda () ((server :quit)
                              (((server :loop) :stop))))
            "say"  (lambda () ((server :privmsg) (list->string (cadr args))
                                (str-concat (map
                                  (lambda (s)
                                    (string-append (list->string s) " "))
                                  (cddr args)))))))

        (if (not (eq? (cmds command) #f))
          ((cmds command))
         else
          ((server :privmsg) (irc-replyto msg) "Dunno what that is man")))
     else
      ((server :privmsg) (irc-replyto msg) "What, no"))))

