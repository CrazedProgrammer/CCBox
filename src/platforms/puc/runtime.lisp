(import computer/event event)
(import lua/io luaio)
(import lua/os luaos)
(import io (read-all!))
(import util (log! run-program!))
(import platforms/puc/input (input->events))

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
        (do [(event (input->events all-input))]
          (if (= event "quit")
            (.<! computer :running false)
            (event/queue! computer event))))
      (with (new-terminal-size (get-term-size-str!))
        (when (/= terminal-size new-terminal-size)
          (set! terminal-size new-terminal-size)
          (event/queue! computer (list "term_resize"))))
      (event/tick! computer)))
  ;; Clear the screen
  (write! "\x1b[0m\x1b[2J")
  ;; Enable cursor blink
  (write! "\x1b[?25h"))
