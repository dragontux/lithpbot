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
  (lambda (host port config)
    (define sock (tcp-socket host port))
    (define nick (assq :nick config))

    (list 'irc-server
          (list :socket sock)
          (list :config config))))

(define irc-user
  (lambda (serv nick)
    (tcp-sendstrings (assq :socket (cdr serv))
      (list "USER " nick " " nick " " nick " :" nick crlf))))

(define irc-nick
  (lambda (serv nick)
    (tcp-sendstrings (assq :socket (cdr serv))
      (list "NICK " nick crlf))))

(define irc-privmsg
  (lambda (serv whom str)
    (tcp-sendstrings (assq :socket (cdr serv))
      (list "PRIVMSG " whom " :" str crlf))))

(define irc-notice
  (lambda (serv whom str)
    (tcp-sendstrings (assq :socket (cdr serv))
      (list "NOTICE " whom " :" str crlf))))

(define irc-join
  (lambda (serv channel)
    (tcp-sendstrings (assq :socket (cdr serv))
      (list "JOIN " channel crlf))))

(define irc-rawmsg
  (lambda (serv str)
    (tcp-writestr (assq :socket (cdr serv)) str)
    (tcp-writestr (assq :socket (cdr serv)) crlf)
    ))

;; Test whether a some thing is an irc server.
;; Returns a boolean which is true if it is a server, false otherwise.
;;
;;    serv: thing to test
(define irc-server?
  (lambda (serv)
    (and (list? serv)
         (eq? (car serv) 'irc-server))))
