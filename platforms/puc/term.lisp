(import lua/io luaio)

(define hex-to-text-colour-code
  { "0" 97
    "1" 33
    "2" 95
    "3" 94
    "4" 93
    "5" 92
    "6" 95
    "7" 90
    "8" 37
    "9" 36
    "a" 35
    "b" 34
    "c" 33
    "d" 32
    "e" 31
    "f" 30 })

(define write! :hidden luaio/write)

(defun run-program! (prg) :hidden
  (let* [(handle (luaio/popen prg))
         (output (self handle :read "*a"))]
    (self handle :close)
    output))

(defun create ()
  { :getSize (lambda ()
               (splice (list (tonumber (run-program! "tput cols"))
                             (tonumber (run-program! "tput lines")))))
    :setCursorPos (lambda (x y)
                    (write! (.. "\x1b[" (tostring y) ";" (tostring x) "H")))
    :setCursorBlink (lambda (blink)
                      (write! (if blink
                                "\x1b[5m"
                                "\x1b[25m")))
    :blit (lambda (str-blit text-blit background-blit)
            (let* [(buffer '())
                   (current-text nil)
                   (current-background nil)]
              (for i 1 (len# str-blit) 1
                (let* [(str-c (string/sub str-blit i i))
                       (text-c (string/sub text-blit i i))
                       (background-c (string/sub background-blit i i))]
                  (when (/= current-text text-c)
                    (push! buffer
                               (.. "\x1b[" (tostring (.> hex-to-text-colour-code text-c)) "m")))
                  (when (/= current-background background-c)
                    (push! buffer
                               (.. "\x1b[" (tostring (+ (.> hex-to-text-colour-code background-c) 10)) "m")))
                  (push! buffer str-c)))
              (write! (concat buffer ""))))
    :scroll (lambda (lines)
              (if (>= lines 0)
                (.. "\x1b[" lines "S")
                (.. "\x1b[" (- 0 lines) "T"))) })
