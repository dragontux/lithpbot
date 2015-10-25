(add-command! ",whoami"
              (lambda [msg]
                (irc-reply msg
                   (concat
                     [irc-field msg :nick] ": Hey there, " 
                     "your host is " [irc-field msg :host]))))
