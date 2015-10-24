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
             "manage.scm"))

(print "hello, world!")
(print "[ ] Starting irc bot.")

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

(define return ident)

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

(define command-list
  (list 
    (list ".bots"         (lambda [msg]
                            (irc-reply msg ;"Reporting in! [Scheme] try ,help"
                                "Reporting in! [4Scheme] try ,help")))

    (list ",source"       (lambda [msg]
                            (irc-reply msg (string-concat
                               (list [irc-field msg :nick] ": https://github.com/dragontux/lithpbot")))))

    (list ",help"         (lambda [msg]
                            (irc-reply msg (string-concat
                                (cons [irc-field msg :nick] (cons ": my commands are: "
                                    (map
                                        (lambda [str]
                                            (if (eq? (string-ref (car str) 0) #\,)
                                                (string-append (car str) " ")
                                                ""))
                                        command-list)))))))

    (list ",whoami"       (lambda [msg]
                            (irc-reply msg (string-append
                                      "Hey there, your host is "
                                      (list->string [msg :host])))))

    (list ",maw"          (lambda [msg]
                            (irc-reply msg (string-concat
                                (list (irc-field msg :nick) ": marf \\(^~^ )7")))))

    (list ",manage"       bot-manage)

    (list ",quote"        (lambda [msg]
                             (let ((split (map list->string
                                               (list-split [msg :message] #\space))))
                               (irc-reply msg (string-concat
                                                (list [irc-field msg :nick]
                                                      ": "
                                                      [get_nick_quote split]))))))

    (list "VERSION"   (lambda [msg]
                            ([server :notice] (irc-field msg :nick)
                                "VERSION I'm an irc bot")))))

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

(define (handle-command msg)
  (foreach command-list
     (lambda (cmd)
       (if (infix [first cmd] = [first split])
         ([cadr cmd] msg)
        else
         '()))))

(define (greet-user msg)
  (if (not (eq? [irc-field msg :nick] [config :nick]))
    (irc-reply msg (concat "Hey there, " [irc-field msg :nick]))
    '()))

(define :mut did-initial? #f)
(add-hook! "PRIVMSG" handle-command)
(add-hook! "JOIN"    greet-user)

(foreach [[server :loop] :iter]
  (lambda (n)
    (let ((message (until #\return tcp-getchar (server :socket))))
      (tcp-getchar (server :socket)) ; just ignore the newline character
      (map display (list "message " n ": "))

      (if (ping? message)
        (begin
          (print "Got ping")
          ([server :rawmsg] (list->string (list-replace message #\I #\O)))

          ; wait for initial ping
          (if (not did-initial?)
            (begin
              (do-initial server)
              (define did-initial? #t))
            '()))

       else
        (let ((msg (parse-irc-message message))
              (split (map list->string (list-split [msg :message] #\space)))
              (wut (open (string-append "logdir/" (list->string [msg :nick])) "a")))

          (handle-hook msg)
          (irc-log-msg-file wut msg)
          (print (map list->string (map msg '(:action :channel :nick :message)))) ))
      '())))
