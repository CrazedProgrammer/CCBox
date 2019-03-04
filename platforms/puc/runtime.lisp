(import computer/event event)
(import lua/io luaio)
(import lua/os luaos)
(import io (read-all!))
(import util (log! run-program!))
(import platforms/puc/keys ())

(define write! :hidden luaio/write)

(defun get-term-size-str! ()
  (.. (run-program! "tput cols") " " (run-program! "tput lines")))

(defun start! (computer)
  (run-program! "stty raw -echo")
  (let* ([terminal-size (get-term-size-str!)]
         [tmp-path (luaos/tmpname)])
    (while (.> computer :running)
      ;; TODO: Fix cursor jumping all around
      (let* ([exit-code (luaos/execute (.. "bash -c 'IFS= read -r -s -t 0.001 CCBOX_INPUT; echo \"$CCBOX_INPUT\" > " tmp-path "' &> /dev/null"))]
             [all-input (read-all! tmp-path)])
        (run-program! "stty raw -echo")
        ((.> computer :term :setCursorPos) ((.> computer :term :getCursorPos)))
        (luaos/execute "sleep 0.049")
        (do [(input (reverse (drop (reverse (string/split all-input "")) 1)))]
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
                          (event/queue! computer (list "char" (cadr keychar)))))))])))
      (with (new-terminal-size (get-term-size-str!))
        (when (/= terminal-size new-terminal-size)
          (set! terminal-size new-terminal-size)
          (event/queue! computer (list "term_resize"))))
      (event/tick! computer)))
  ;; Clear the screen
  (write! "\x1b[0m\x1b[2J")
  ;; Enable cursor blink
  (write! "\x1b[?25h"))
