(import computer/event event)
(import lua/io luaio)
(import util (log! run-program!))
(import platforms/puc/keys ())

(defun start! (computer)
  (run-program! "stty raw -echo")
  (while (.> computer :running)
    (with (input (luaio/read 1))
      (case input
        ["\x03" (.<! computer :running false)]
        ["\x14" (event/queue! computer (list "terminate"))]
        [else (with (keychar (parse-key (list input)))
                (when keychar ; TODO: handle all characters, including those with escape codes (for example the arrow keys).
                  (progn
                    (when (car keychar)
                      (event/queue! computer (list "key" (car keychar)))
                      (event/queue! computer (list "key_up" (car keychar))))
                    (when (cadr keychar)
                      (event/queue! computer (list "char" (cadr keychar)))))))]))
    (event/tick! computer))
  ;; Clear the screen
  (luaio/write "\x1b[0m\x1b[2J"))
