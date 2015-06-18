#!/usr/bin/env gojira
(import! 'srfi1)

; todo: move this to seperate configuration file
(define config
   '((:server   "irc.rizon.net")
     (:port     6667)
     (:nick     "cpt_ahab")
     (:channels ("#/g/bots"))))

(map load! '("misc.scm"
             "irc.scm"))

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

(irc-privmsg serv "NickServ" "identify *****")
(foreach [iota 5] intern-sleep)

(foreach (assq :channels config)
  (lambda (chan)
    (display "[ ] Joining ") (print chan)
    (irc-join serv chan)))

(foreach [iota 100]
         (lambda (n)
           (define message (until #\return tcp-getchar (assq :socket (cdr serv))))
           (tcp-getchar (assq :socket (cdr serv))) ; just ignore the newline character

           (if (list-equal? (take message 4) (str-iter "PING"))
             (begin
               (display "[ ] Got ping: ")
               (print message)
               (irc-rawmsg serv (list->string (list-replace message #\I #\O))))
             (begin
               (display "    ")
               (define split (list-split message #\ ))
               (define channel      (list-ref split 2))
               (define user-message (list-ref split 3))

               (map display (list channel " " user-message))

               (if (list-equal? user-message (str-iter ":.bots"))
                 (irc-privmsg serv (list->string channel) "Reporting in! [Scheme]")
                 'uwot)

               ;(display (list->string (take message 60)))
               (print "..."))
           )))

(map (lambda (n) (intern-sleep) (print n)) [iota 100])
