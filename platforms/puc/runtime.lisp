(import computer/event event)
(import lua/io luaio)
(import util (log! run-program!))

(defun start! (computer)
  (run-program! "stty raw -echo")
  (while (.> computer :running)
    ;; TODO: Proper keyboard mapping (stdin keycode to char and cc key code)
    (with (input (luaio/read 1))
      (case input
        ["\x03" (.<! computer :running false)]
        ["\x0d" (progn
                  (event/queue! computer (list "key" 28 false))
                  (event/queue! computer (list "key_up" 28)))]
        ["\x14" (event/queue! computer (list "terminate"))]
        [else (progn
                (event/queue! computer (list "char" input)))]))
    (event/tick! computer))
  ;; Clear the screen
  (luaio/write "\x1b[0m\x1b[2J"))
