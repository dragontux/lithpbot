(add-command! ",source"
              (lambda [msg]
                (irc-reply msg (string-concat
                     (list [irc-field msg :nick] ": https://github.com/dragontux/lithpbot")))))

