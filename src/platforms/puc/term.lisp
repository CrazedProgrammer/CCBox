(import lua/io luaio)
(import lua/table luatable)
(import util (write! log! run-program!))

;; TODO: Improve performance
;; TODO: Use unicode characters for characters in the upper range

(define char-map
  (assoc->struct (map (lambda (code)
                        (list (string/char code)
                          (cond
                            [(< code 32) " "]
                            [(> code 126) " "]
                            [true (string/char code)])))
                      (range :from 0 :to 255))))

(defun fallback-color-char (hex-char) :hidden
  ;; TODO: Create a lookup table for this
  (if (tonumber hex-char 16)
    (string/lower hex-char)
    "f"))

(defun rgb-to-colour256 (r g b) :hidden
  (let* [(r6 (math/min 5 (math/floor (* r 6))))
         (g6 (math/min 5 (math/floor (* g 6))))
         (b6 (math/min 5 (math/floor (* b 6))))]
    (+ 16 (* 36 r6) (* 6 g6) b6)))

(defun colour-to-hex (colour) :hidden
  (string/format "%01x" (/ (math/log colour) (math/log 2))))

(defun create ()
  (with (palette-colour256-str { })
    { :getSize (lambda ()
                 (splice (list (tonumber (run-program! "tput cols"))
                               (tonumber (run-program! "tput lines")))))
      :setCursorPos (lambda (x y)
                      (write! (.. "\x1b[" (tostring y) ";" (tostring x) "H")))
      :setCursorBlink (lambda (blink)
                        (write! (if blink
                                  "\x1b[?25h"
                                  "\x1b[?25l")))
      :blit (lambda (str-blit text-blit background-blit)
              (let* [(buffer '())
                     (current-text nil)
                     (current-background nil)]
                (for i 1 (len# str-blit) 1
                  (let* [(str-c (.> char-map (string/sub str-blit i i)))
                         (text-c (string/sub text-blit i i))
                         (background-c (string/sub background-blit i i))]
                    (when (/= current-text text-c)
                      (push! buffer
                             (.. "\x1b[38:5:" (.> palette-colour256-str (fallback-color-char text-c)) "m")))
                    (when (/= current-background background-c)
                      (push! buffer
                             (.. "\x1b[48:5:" (.> palette-colour256-str (fallback-color-char background-c)) "m")))
                    (push! buffer str-c)))
                (write! (luatable/concat buffer ""))))
      :scroll (lambda (lines)
                (if (>= lines 0)
                  (.. "\x1b[" lines "S")
                  (.. "\x1b[" (- 0 lines) "T")))
      :setPaletteColour (lambda (colour r g b)
                          (.<! palette-colour256-str (colour-to-hex colour) (tostring (rgb-to-colour256 r g b)))) }))
