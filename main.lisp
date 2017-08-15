(import computer)
(import bindings/os os)
(import bindings/native (args))
(import bindings/shell shell)
(import debug)

(let* [(prog-args { :boot (shell/resolve (or (car args) "bios.lua")) })
       (comp (computer/create (.> prog-args :boot)))]
  (while true
    (computer/next comp (list (os/pullEventRaw)))))
