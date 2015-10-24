(import! 'lists)

(define crlf (list->string '(#\return #\newline)))

(define tcp-sendstrings
  (lambda (sock strs)
    (foreach strs
       (lambda (str) (tcp-writestr sock str)))))

;; Connects to an irc server.
(define irc-connect
  (lambda (config)
    (define sock (tcp-socket (config :server) (config :port)))
    (define nick (config :nick))

    (hashmap
      :config    config
      :socket    sock
      :loop      (loop-iter)

      :user      (lambda (nick)
                   (tcp-sendstrings sock
                                    (list "USER " nick " " nick " " nick " :" nick crlf)))

      :nick      (lambda (nick)
                   (tcp-sendstrings sock
                                    (list "NICK " nick crlf)))

      :privmsg   (lambda (whom str)
                   (tcp-sendstrings sock
                                    (list "PRIVMSG " whom " :" str crlf)))

      :notice    (lambda (whom str)
                   (tcp-sendstrings sock
                                    (list "NOTICE " whom " :" str crlf)))

      :join      (lambda (channel)
                   (tcp-sendstrings sock
                                    (list "JOIN " channel crlf)))

      :part      (lambda (channel)
                   (tcp-sendstrings sock
                                    (list "PART " channel crlf)))

      :quit      (lambda ()
                   (tcp-sendstrings sock
                                    (list "QUIT :foo" crlf)))

      :rawmsg    (lambda (str)
                   (tcp-writestr sock str)
                   (tcp-writestr sock crlf)))))

(define (irc-log-msg msg)
  (irc-log-msg-file log-file))

(define (irc-log-msg-file f msg)
    (write (map list->string (map msg '(:nick :host :channel :message)))
           f))

(define (ping? xs)
  (equal? (take xs 4) (str-iter "PING")))

(define irc-field (lambda [msg val] (list->string [msg val])))

(define (irc-replyto msg)
  (if (eq? (car (msg :channel)) #\#)
    (list->string [msg :channel])
    (list->string [msg :nick])))

(define (parse-irc-message msg)
  (let ((split (list-split msg #\space)))
    (hashmap
      :channel  (let ((chan (list-ref split 2)))
                      (if (eq? (car chan) #\:)
                        (cdr chan)
                        chan))
      :message  (after (after msg #\:) #\:)
      :who      (car split)
      :action   (cadr split)
      :nick     (after (delim (car split) #\!) #\:)
      :host     (after (car split) #\@))))

