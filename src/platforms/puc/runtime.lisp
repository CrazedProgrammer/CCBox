(import computer/event event)
(import lua/io luaio)
(import lua/os luaos)
(import io (read-all!))
(import util (write!))
(import util/io (run-program!))
(import platforms/puc/input (input->events))
(import platforms/puc/term (flush-write-buffer!))
(import platforms/puc (get-time!))

(define target-tick-interval :hidden 0.05)
(define check-term-size-ticks :hidden 20)

(defun get-term-size-str! () :hidden
  (.. (run-program! "tput cols") " " (run-program! "tput lines")))

(defun start! (computer)
  (run-program! "stty raw -echo")
  ;; Enable mouse click tracking with SGR extended attributes
  (write! "\x1b[?1002h")
  (write! "\x1b[?1006h")

  (let* ([tick-counter 0]
         [terminal-size (get-term-size-str!)]
         [tmp-path (luaos/tmpname)])
    (while (.> computer :running)
      (let* ([exit-code (luaos/execute (.. "bash -c 'IFS= read -r -s -t 0.001 CCBOX_INPUT; echo \"$CCBOX_INPUT\" > " tmp-path "' &> /dev/null"))]
             [all-input (read-all! tmp-path)]
             [start-time (get-time!)])
        (run-program! "stty raw -echo")
        ;; Reset cursor position back to where the emulated computer has it
        ((.> computer :term :setCursorPos) ((.> computer :term :getCursorPos)))
        ;; Parse new inputs and push them to the event stack
        (do [(event (input->events all-input))]
          (if (= event "quit")
            (.<! computer :running false)
            (event/queue! computer event)))

        ;; Check for and apply changes in terminal size
        (when (= (mod tick-counter check-term-size-ticks) 0)
          (with (new-terminal-size (get-term-size-str!))
            (when (/= terminal-size new-terminal-size)
              (set! terminal-size new-terminal-size)
              (event/queue! computer (list "term_resize")))))
        ;; Run events
        (event/tick! computer)
        ;; Flush write buffer
        (flush-write-buffer!)
        ;; Sleep until the tick has taken 50ms
        (with (sleep-time (- target-tick-interval (- (get-time!) start-time)))
          (when (> sleep-time 0)
            (luaos/execute (string/format "sleep %03f" sleep-time)))))
      (inc! tick-counter))
    (luaos/remove tmp-path))
  ;; Clear the screen
  (write! "\x1b[0m\x1b[2J")
  ;; Disable mouse click tracking
  (write! "\x1b[?1002l")
  (write! "\x1b[?1006l")
  ;; Enable cursor blink
  (write! "\x1b[?25h"))
