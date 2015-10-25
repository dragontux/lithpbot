(add-command! ",help"
              (lambda [msg]
                (irc-reply msg (string-concat
                    (cons [irc-field msg :nick] (cons ": my commands are: "
                        (map
                            (lambda [str]
                                (if (eq? (string-ref (car str) 0) #\,)
                                    (string-append (car str) " ")
                                    ""))
                            *commands*)))))))

