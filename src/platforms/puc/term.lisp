(import lua/io luaio)
(import lua/table luatable)
(import util (write! log! run-program! push-table!))
(import math/bit32 (bit-extract))

;; TODO: Improve performance
;; TODO: Use unicode characters for characters in the upper range

;; TODO: Find some way to draw 6-cell characters instead of 4-cell characters
(defun block-char->unicode (code) :hidden
  (let* [(entry-num (- code 128))
         (quadrants (+ 1
                       (* 1 (bit-extract code 0))
                       (* 2 (bit-extract code 1))
                       (* 4 (bit-extract code 2))
                       (* 8 (bit-extract code 3))))]
    (if (= quadrants 1)
      " "
      (.. "\xE2\x96"
          (string/sub (.. "\xFF\x98\x9D\x80"
                          "\x96\x8C\x9E\x9B"
                          "\x97\x9A\x90\x9C"
                          "\x84\x99\x9F\x88")
                      quadrants
                      quadrants)))))

(define char-map :hidden
  (assoc->struct (map (lambda (code)
                        (list (string/char code)
                          (cond
                            [(and (>= code 32) (< code 127)) (string/char code)]
                            [(= code 127) "\xE2\x96\x92"]
                            [(and (>= code 128) (< code 160)) (block-char->unicode code)]
                            [(and (>= code 161) (< code 192)) (.. "\xC2" (string/char code))]
                            [(and (>= code 192) (< code 256)) (.. "\xC3" (string/char (- code 64)))]
                            [else " "])))
                      (range :from 0 :to 255))))

(define fallback-color-char-map :hidden
  (assoc->struct (map (lambda (code)
                        (with (hex-char (string/char code))
                          (list
                            hex-char
                            (if (tonumber hex-char 16)
                              (string/lower hex-char)
                              "f"))))
                      (range :from 0 :to 255))))

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
              (let* [(buffer {})
                     (current-text nil)
                     (current-background nil)]
                (for i 1 (len# str-blit) 1
                  (let* [(str-c (.> char-map (string/sub str-blit i i)))
                         (text-c (string/sub text-blit i i))
                         (background-c (string/sub background-blit i i))]
                    (when (/= current-text text-c)
                      (push-table! buffer
                                   (.. "\x1b[38:5:" (.> palette-colour256-str (.> fallback-color-char-map text-c)) "m")))
                    (when (/= current-background background-c)
                      (push-table! buffer
                                   (.. "\x1b[48:5:" (.> palette-colour256-str (.> fallback-color-char-map background-c)) "m")))
                    (push-table! buffer str-c)))
                (write! (luatable/concat buffer ""))))
      :scroll (lambda (lines)
                (if (>= lines 0)
                  (.. "\x1b[" lines "S")
                  (.. "\x1b[" (- 0 lines) "T")))
      :setPaletteColour (lambda (colour r g b)
                          (.<! palette-colour256-str (colour-to-hex colour) (tostring (rgb-to-colour256 r g b)))) }))
