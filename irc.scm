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

