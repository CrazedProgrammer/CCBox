(import computer/event event)
(import lua/io luaio)
(import util (log!))

(defun start! (computer)
  (while (.> computer :running)
    (with (input (luaio/read "*l"))
      (do [(input-char (string/split input ""))]
        ;; TODO: proper keyboard mapping
        (event/queue! computer (list "char" input-char)))
      (event/queue! computer (list "key" 28 false))
      (event/queue! computer (list "key_up" 28))
      (event/tick! computer))))
