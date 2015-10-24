(import! 'lists)
(import! 'strings)

(define bot-manage
  (lambda (msg)
    (define args (list-split (after (msg :message) #\space) #\space))

    (if (and (eq? (irc-field msg :nick) "callcc")
             (eq? (irc-field msg :host) "the.innernet")
             (> (length args) 0))
      (let
        ((command (list->string (car args)))
         (cmds
            (hashmap
              "join"  (lambda () ((server :join) (list->string (cadr args))))
              "debug" (lambda () (debug-break))
              "part"  (lambda () ((server :part) (list->string (cadr args))))
              "quit"  (lambda () ((server :quit)
                                 (((server :loop) :stop))))
              "say"   (lambda () ((server :privmsg) (list->string (cadr args))
                                  (string-concat (map
                                    (lambda (s)
                                      (string-append (list->string s) " "))
                                    (cddr args))))))))

        (if (not (eq? (cmds command) #f))
          ((cmds command))
         else
          ((server :privmsg) (irc-replyto msg) "Dunno what that is man")))
     else
      ((server :privmsg) (irc-replyto msg) "What, no"))))

