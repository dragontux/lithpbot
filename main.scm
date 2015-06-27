#!/usr/bin/env gojira
(import! 'lists)

; todo: move this to seperate configuration file
(define config
   '((:server   "irc.rizon.net")
     (:port     6667)
     (:nick     "cpt_ahab")
     (:channels ("#cpt_ahab"))))

(map load! '("misc.scm"
             "irc.scm"
             "manage.scm"))

(print "hello, world!")
(print "[ ] Starting irc bot.")

(define serv (irc-connect
               (assq :server config)
               (assq :port   config)
               config))

(irc-user serv (assq :nick config))
(irc-nick serv (assq :nick config))

(print "[ ] Connected to server.")
(display "[ ] Have server: ") (print serv)

(irc-privmsg serv "NickServ"
             (string-append "identify " (readall (open "./passfile" "r"))))
(foreach [iota 5] intern-sleep)

(foreach (assq :channels config)
  (lambda (chan)
    (display "[ ] Joining ") (print chan)
    (irc-join serv chan)))

(define parse-irc-message
  (lambda (msg)
     (define split (list-split msg #\ ))

     (list
       (list :channel   (list-ref split 2))
       (list :message   (after (after msg #\:) #\:))
       (list :who       (car split))
       (list :action    (cadr split))

       (list :nick      (after (delim (car split) #\!) #\:))
       (list :host      (after (car split) #\@)))
     ))

(define irc-field
  (lambda (msg val)
    (list->string (assq val msg))))

(define irc-replyto
  (lambda (msg)
    (if (eq? (car (assq :channel msg)) #\#)
      (list->string (assq :channel msg))
      (list->string (assq :nick msg)))))

(define str-concat
  (lambda (xs)
    (if (null? xs)
      ""
      (string-append (car xs) (str-concat (cdr xs))))))

(define command-list
  (list (list ".bots"
              (lambda (msg)
                (irc-privmsg serv (irc-replyto msg) "Reporting in! [4Scheme] try ,help")))

        (list ",source"
              (lambda (msg)
                (irc-privmsg serv (irc-replyto msg) "[todo] insert source link here")))

        (list ",help"
              (lambda (msg)
                (irc-privmsg serv (irc-replyto msg)
                             (str-concat
                               (list (irc-field msg :nick) ": sorry, I don't have a help command at the moment...")))))

        (list ",command_test"
              (lambda (msg)
                (define args (list-split (after (assq :message msg) #\ ) #\ ))

                (irc-privmsg serv (irc-replyto msg)
                             "Testing, systems be nominal. Args list: ")

                (foreach args
                  (lambda (arg)
                    (irc-privmsg serv (irc-replyto msg) (list->string arg))))))

        (list ",whoami"
              (lambda (msg)
                (irc-privmsg serv (irc-replyto msg)
                             (string-append "Hey there, your host is "
                                            (list->string (assq :host msg))))))

        (list ",maw"
              (lambda (msg)
                (irc-privmsg serv (irc-replyto msg)
                             (str-concat
                               (list (irc-field msg :nick) ": marf \\(^~^ )7")))))

        (list ",manage" bot-manage)

        (list "VERSION"
              (lambda (msg)
                (irc-notice serv (irc-field msg :nick)
                            "VERSION I'm an irc bot")))
        ))


(foreach [iterator ident] ; loop forever, generates an infinite list
  (lambda (n)
    (define message (until #\return tcp-getchar (assq :socket (cdr serv))))
    (tcp-getchar (assq :socket (cdr serv))) ; just ignore the newline character
    (map display (list "message " n ": "))

    (if (equal? (take message 4) (str-iter "PING"))
      (begin
        (display "[ ] Got ping: ")
        (print message)
        (irc-rawmsg serv (list->string (list-replace message #\I #\O))))

      (begin
        (define parsed (parse-irc-message message))

        (display "    ")
        (map display (list (list->string (assq :nick parsed))
                           "@"
                           (list->string (assq :host parsed))
                           ": "
                           (list->string (assq :action parsed))))
        (print "")

        (if (not (null? (assq :message parsed)))
          (foreach command-list
                   (lambda (command)
                     (if (equal? (map ident (str-iter (car command)))
                                 (take (assq :message parsed) (string-length (car command))))
                       ((cadr command) parsed)
                       'uwot)))
          'm8)))))
