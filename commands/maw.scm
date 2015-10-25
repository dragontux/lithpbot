(add-command! ",maw"
              (lambda [msg]
                (irc-reply msg (string-concat
                  (list (irc-field msg :nick) ": marf \\(^~^ )7")))))
