#!/usr/bin/env gojira

(map import! '(lists math strings))

; todo: move this to seperate configuration file
(define config 
  (hashmap
    :server   "irc.rizon.net"
    :port     6667
    :nick     "cpt_ahab"
    :channels '("#cpt_ahab")))

(map load! '("misc.scm"
             "irc.scm"
             "hooks.scm"
             "commands.scm"))

(print "[ ] Starting lithpbot.")

(define server (irc-connect config))

([server :user] (config :nick))
([server :nick] (config :nick))
(print "[ ] Connected to server.")
(display "[ ] Have server: ")
(print server)

(define (irc-reply msg str)
  ([server :privmsg] [irc-replyto msg] str))

(define (string-strip str chars)
    (list->string (filter
        (lambda (c) (not (member? c chars)))
        (str-iter str))))

(map load-command! '("manage"  "quote" "help"   "maw"
                     "version" "bots"  "whoami" "source"))

(if (not (exists? "logdir"))
    (mkdir "logdir")
    '())

(define str-strip (func [tokens str]
    (list->string (filter (func [c] (not (member? c tokens))) (str-iter str)))))

(define (do-initial serv)
  ([serv :privmsg] "NickServ"
     (string-append "identify " (readall (open "./passfile" "r"))))

  ; XXX: wait for the vhost to be set, hopefully
  (intern-sleep)

  (foreach [config :channels]
    (lambda (chan)
      (display "[ ] Joining ")
      (print chan)
      ([serv :join] chan))))

(define :mut did-initial? #f)

(define (handle-end-of-motd msg)
  (if (not did-initial?)
    (begin
      (do-initial server)
      (define did-initial? #t))
    '()))

(define (greet-user msg)
  (if (not (eq? [irc-field msg :nick] [config :nick]))
    (irc-reply msg (concat "Hey there, " [irc-field msg :nick]))
    '()))

(add-hook! "PRIVMSG" handle-command)
;(add-hook! "JOIN"    greet-user)
(add-hook! "376"     handle-end-of-motd)

(foreach [[server :loop] :iter]
  (lambda (n)
    (let ((message (until #\return tcp-getchar (server :socket))))
      (tcp-getchar (server :socket)) ; just ignore the newline character
      (map display (list "message " n ": "))

      (if (ping? message)
        (begin
          (print "Got ping")
          ([server :rawmsg] (list->string (list-replace message #\I #\O))))

       else
        (let ((msg (parse-irc-message message))
              (split (map list->string (list-split [msg :message] #\space)))
              (wut (open (string-append "logdir/" (list->string [msg :nick])) "a")))

          (print (map list->string (map msg '(:action :channel :nick :message))))
          (irc-log-msg-file wut msg)
          (handle-hook msg)))
      '())))
