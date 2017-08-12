(import computer)
(import bindings/os os)

(with (comp (computer/create))
  (while true
    (computer/next comp (list (os/pullEvent)))))
