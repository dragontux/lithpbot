(add-command! ",quote"
  (begin
    (define (get_nick_quote args)
      (if (infix (length args) > 1)

        (let ((nick (string-strip (list-ref args 1) '(#\. #\/))))
          (if (exists? (string-append "logdir/" nick))
            (let ((logs (read (open (string-append "logdir/" nick) "r"))))
              (list-ref (random_choice logs) 3))
            else
            "I haven't seen them, sry"))
        else
        "Usage: ,quote [nick]"))

    (lambda [msg]
      (let ((split (map list->string
                        (list-split [msg :message] #\space))))
        (irc-reply msg (string-concat
                         (list [irc-field msg :nick]
                               ": "
                               [get_nick_quote split])))))))
