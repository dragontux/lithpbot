#!/usr/bin/env gojira
(import! 'srfi1)

; todo: move this to seperate configuration file
(define config
  '((:server  "irc.rizon.net")
    (:port    6667)
    (:nick    "cpt_ahab")))

(print "hello, world!")
