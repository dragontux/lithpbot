(import! 'lists)

(define crlf (list->string '(#\return #\newline)))

(define tcp-sendstrings
  (lambda (sock strs)
    ;(map (lambda (str) (tcp-writestr sock str))
    (foreach strs
       (lambda (str) (tcp-writestr sock str)))))

;; Connect to an irc server.
;; Returns a list representing a server connection.
;;
;;    host: Domain, IP, hostname, etc. of the server.
;;          Must be able to be resolved by gethostbyname(3).
;;    port: The TCP port of the server to connect to.
;;  config: List of config parameters, defined in main.scm.
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

;; Test whether a some thing is an irc server.
;; Returns a boolean which is true if it is a server, false otherwise.
;;
;;    serv: thing to test
(define irc-server?
  (lambda (serv)
    (and (list? serv)
         (eq? (car serv) 'irc-server))))
