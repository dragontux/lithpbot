#!/usr/bin/env gojira

(map import! '(lists math))

; todo: move this to seperate configuration file
(define config 
  (hashmap
    :server   "irc.rizon.net"
    :port     6667
    :nick     "cpt_ahab"
    :channels '["#cpt_ahab"]))

(map load! '("misc.scm"
             "irc.scm"
             "manage.scm"))

(print "hello, world!")
(print "[ ] Starting irc bot.")

(define server (irc-connect config))

([server :user] (config :nick))
([server :nick] (config :nick))
(print "[ ] Connected to server.")
(display "[ ] Have server: ")
(print server)

([server :privmsg] "NickServ"
   (string-append "identify " (readall (open "./passfile" "r"))))

(foreach [iota 5] intern-sleep)

(foreach [config :channels]
  (lambda (chan)
    (display "[ ] Joining ")
    (print chan)
    ([server :join] chan)))

(define parse-irc-message (lambda (msg)
     (define split (list-split msg #\space))
     (hashmap
       :channel  (list-ref split 2)
       :message  (after (after msg #\:) #\:)
       :who      (car split)
       :action   (cadr split)
       :nick     (after (delim (car split) #\!) #\:)
       :host     (after (car split) #\@))))

(define irc-field (lambda [msg val] (list->string [msg val])))

(define irc-replyto (lambda [msg]
    (if (eq? (car (msg :channel)) #\#)
      (list->string [msg :channel])
      (list->string [msg :nick]))))

(define str-concat (lambda [xs]
    (if (null? xs)
      ""
      (string-append (car xs) (str-concat (cdr xs))))))

(define irc-reply (func [msg str]
    ([server :privmsg] [irc-replyto msg] str)))

(define string-strip (lambda [str chars]
    (list->string (filter
        (lambda (c) (not (member? c chars)))
        (str-iter str)))))

(define return ident)

(define get_nick_quote (lambda (args)
    (if (infix (length args) > 1)
        (begin
            (define nick (string-strip (list-ref args 1) '(#\. #\/)))
            (if (exists? (string-append "logdir/" nick))
                (begin
                    (define logs (read (open (string-append "logdir/" nick) "r")))
                    (list-ref (random_choice logs) 3))
                "I haven't seen them, sry"))
        "Usage: ,quote [nick]")))

(define command-list
  (list 
    (list ".bots"         (lambda [msg]
                            (irc-reply msg ; "Reporting in! [4Scheme] try ,help"
                                ("Reporting in! [Scheme] try ,help"))))

    (list ",source"       (lambda [msg]
                            (irc-reply msg (str-concat
                               (list [irc-field msg :nick] ": https://github.com/dragontux/lithpbot")))))

    (list ",help"         (lambda [msg]
                            (irc-reply msg (str-concat
                                (cons [irc-field msg :nick] (cons ": my commands are: "
                                    (map
                                        (func [str]
                                            (if (eq? (string-ref (car str) 0) #\,)
                                                (string-append (car str) " ")
                                                ""))
                                        command-list)))))))

    (list ",whoami"       (func [msg]
                            (irc-reply msg (string-append
                                      "Hey there, your host is "
                                      (list->string [msg :host])))))

    (list ",maw"          (func [msg]
                            (irc-reply msg (str-concat
                                (list (irc-field msg :nick) ": marf \\(^~^ )7")))))

    (list ",manage"       bot-manage)

    (list ",quote"        (func [msg]
                            (define split (map list->string (list-split [msg :message] #\space)))
                            (irc-reply msg (str-concat
                                (list [irc-field msg :nick] ": " [get_nick_quote split])))))

    (list "VERSION"   (func [msg]
                            ([server :notice] (irc-field msg :nick)
                                "VERSION I'm an irc bot")))))

(define ping? (func [xs] (equal? (take xs 4) (str-iter "PING"))))

(define write (func [f x]
    (display x f)
    (newline f)))

(define irc-log-msg (func [msg]
    (write log-file (map list->string (list
                   [msg :nick] [msg :host] [msg :channel] [msg :message])))))

(define irc-log-msg-file (func [f msg]
    (write f (map list->string (list
            [msg :nick] [msg :host] [msg :channel] [msg :message])))))

(if (not (exists? "logdir"))
    (mkdir "logdir")
    '())

(define str-strip (func [tokens str]
    (list->string (filter (func [c] (not (member? c tokens))) (str-iter str)))))

(foreach [[server :loop] :iter] (func [n]
    (define message (until #\return tcp-getchar (server :socket)))
    (tcp-getchar (server :socket)) ; just ignore the newline character
    (map display (list "message " n ": "))

    (if (ping? message)
        (begin
            (print "Got ping")
            ([server :rawmsg] (list->string (list-replace message #\I #\O))))

        (begin
            (define msg [parse-irc-message message])
            (define split (map list->string (list-split [msg :message] #\space)))
            (define wut (open (string-append "logdir/" (list->string [msg :nick])) "a"))

            (irc-log-msg-file wut msg)

            (foreach command-list (func [cmd]
                (if (infix [first cmd] = [first split])
                   ([cadr cmd] msg)
                   '())))

            ;(print ([parse-irc-message message] :action))))
            ;(print (list->string (msg :action)))))
            (print (map list->string (map msg '(:action :nick :message)))) ))
    '()))
