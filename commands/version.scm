(add-command! "VERSION"
              (lambda [msg]
                ([server :notice] (irc-field msg :nick)
                  "VERSION I'm an irc bot")))
