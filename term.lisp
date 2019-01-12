(import util (demand-type! log!))

(define colour-to-hex :hidden
  (assoc->struct (map (lambda (colour-n)
                        (list (expt 2 colour-n) (string/format "%01x" colour-n)))
                      (range :from 0 :to 15))))

(define supported-colours :hidden
  (map (cut expt 2 <>) (range :from 0 :to 15)))
(define supported-bw-colours '(0 128 256 32768))

(defun assert-colour! (colour is-colour) :hidden
  (demand-type! colour "number")
  (demand (elem? colour (if is-colour
                          supported-colours
                          supported-bw-colours))))

;;; Reduce required functions of the native terminal implementation to:
;;; - getSize
;;; - setCursorPos
;;; - setCursorBlink
;;; - blit
;;; - scroll
(defun create-term (native-term is-colour)
  (letrec
    [(cursor-x 1)
     (cursor-y 1)
     (cursor-blink false)
     (text-colour 1) ; White
     (background-colour 32768) ; Black
     (term
       { :getSize (.> native-term :getSize)
         :scroll (.> native-term :scroll)
         :getCursorPos (lambda ()
                         (splice (list cursor-x cursor-y)))
         :setCursorPos (lambda (x y)
                         (demand-type! x "number")
                         (demand-type! y "number")
                         (set! cursor-x (math/floor x))
                         (set! cursor-y (math/floor y))
                         ((.> native-term :setCursorPos) cursor-x cursor-y))
         :setCursorBlink (lambda (blink)
                           (demand-type! blink "boolean")
                           (set! cursor-blink blink)
                           ((.> native-term :setCursorBlink) cursor-blink))
         :isColour (const is-colour)

         :getTextColour (lambda ()
                         text-colour)
         :getBackgroundColour (lambda ()
                         background-colour)
         :setTextColour (lambda (colour)
                          (assert-colour! colour is-colour)
                          (set! text-colour colour))
         :setBackgroundColour (lambda (colour)
                          (assert-colour! colour is-colour)
                          (set! background-colour colour))
         :getPaletteColour (lambda (colour)
                             (assert-colour! colour is-colour)
                             (if (.> native-term :getPaletteColour)
                               ((.> native-term :getPaletteColour) colour)
                               ;; TODO: add lookup table for predefined colours. Maybe keep track of custom palettes set by setPaletteColour?
                               (splice (list 0 0 0))))
         :setPaletteColour (lambda (colour r g b)
                             (assert-colour! colour is-colour)
                             (when (or r g b)
                               (demand-type! r "number")
                               (demand-type! g "number")
                               (demand-type! b "number"))
                             (when (.> native-term :setPaletteColour)
                               ((.> native-term :setPaletteColour) colour r g b)))

         :clearLine (lambda ()
                      (let* [((prev-cursor-x prev-cursor-y) ((.> term :getCursorPos)))
                             ((term-width term-height) ((.> term :getSize)))]
                        ((.> term :setCursorPos) 1 prev-cursor-y)
                        ((.> term :write) (string/rep " " term-width))
                        ((.> term :setCursorPos) prev-cursor-x prev-cursor-y)))
         :clear (lambda ()
                  (let* [((prev-cursor-x prev-cursor-y) ((.> term :getCursorPos)))
                         ((term-width term-height) ((.> term :getSize)))]
                    (for i 1 term-height 1
                      ((.> term :setCursorPos) 1 i)
                      ((.> term :write) (string/rep " " term-width)))
                    ((.> term :setCursorPos) prev-cursor-x prev-cursor-y)))

         :write (lambda (val)
                  (let* [(str (tostring val))
                         (str-len (len# str))]
                    ((.> term :blit) str
                                     (string/rep (.> colour-to-hex text-colour) str-len)
                                     (string/rep (.> colour-to-hex background-colour) str-len))))
         :blit (lambda (blit-str blit-text blit-background)
                 (demand-type! blit-str "string")
                 (demand-type! blit-background "string")
                 (demand-type! blit-text "string")
                 (set! cursor-x (+ cursor-x (len# blit-str)))
                 ((.> native-term :blit) blit-str blit-text blit-background)) })]
    ;; Reset native cursor to its standard position
    ((.> native-term :setCursorPos) cursor-x cursor-y)
    ((.> native-term :setCursorBlink) cursor-blink)
    ;; Add aliases
    (merge term
           { :isColor (.> term :isColour)
              :getTextColor (.> term :getTextColour)
              :getBackgroundColor (.> term :getBackgroundColour)
              :setTextColor (.> term :setTextColour)
              :setBackgroundColor (.> term :setBackgroundColour)
              :getPaletteColor (.> term :getPaletteColour)
              :setPaletteColor (.> term :setPaletteColour) })))
