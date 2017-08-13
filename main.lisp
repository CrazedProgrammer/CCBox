(import computer)
(import bindings/os os)

(with (comp (computer/create "bios.lua"))
  (while true
    (computer/next comp (list (os/pullEvent)))))
