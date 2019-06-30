(import util/test (run-test-scripts!))

(define test-scripts
  (list
    (list "can keep track of the cursor position"
          "term.setCursorPos(12, 34)
           testlog.write({term.getCursorPos()})
           term.setCursorPos(1, 1)
           testlog.write({term.getCursorPos()})"
          (list {1 12 2 34} {1 1 2 1}))
    (list "can keep track of the text and background colour"
          "term.setTextColor(8192)
           term.setBackgroundColor(1024)
           testlog.write(term.getTextColor())
           testlog.write(term.getBackgroundColor())
           term.setTextColour(1)
           term.setBackgroundColour(32768)
           testlog.write(term.getTextColour())
           testlog.write(term.getBackgroundColour())"
          (list 8192 1024 1 32768))
    (list "can return the palette colours"
          "for i = 0, 15 do
             local r1, g1, b1 = term.getPaletteColour(2 ^ i)
             local r2, g2, b2 = term.getPaletteColor(2 ^ i)
             testlog.write(type(r1) == \"number\" and r1 >= 0 and r1 <= 1.0)
             testlog.write(type(g1) == \"number\" and g1 >= 0 and g1 <= 1.0)
             testlog.write(type(b1) == \"number\" and b1 >= 0 and b1 <= 1.0)
             testlog.write(type(r2) == \"number\" and r2 >= 0 and r2 <= 1.0)
             testlog.write(type(g2) == \"number\" and g2 >= 0 and g2 <= 1.0)
             testlog.write(type(b2) == \"number\" and b2 >= 0 and b2 <= 1.0)
           end"
          (map (const true) (range :from 1 :to 96)))
    (list "can set palette colours"
          "term.setPaletteColour(32768, 0.2, 0.2, 0.2)
           testlog.write({term.getPaletteColour(32768)})
           term.setPaletteColor(32768, 0.1, 0.1, 0.1)
           testlog.write({term.getPaletteColor(32768)})
           term.setPaletteColour(32768)"
          (list {1 0.2 2 0.2 3 0.2} {1 0.1 2 0.1 3 0.1}))
    (list "can set cursor blink"
          "term.setCursorBlink(true)
           term.setCursorBlink(false)"
          (list))
    (list "can return whether it's a colour monitor"
          "testlog.write(type(term.isColour()))
           testlog.write(type(term.isColor()))"
          (list "boolean" "boolean"))
    (list "can clear a screen"
          "term.clear()"
          (list))
    (list "can clear a line"
          "term.clearLine()"
          (list))
    (list "can scroll up and down"
          "term.scroll(-1)
           term.scroll(0)
           term.scroll(1)"
          (list))
    (list "can return its size"
          "local width, height = term.getSize()
           testlog.write(type(width))
           testlog.write(type(height))
           testlog.write(width > 0)
           testlog.write(height > 0)"
          (list "number" "number" true true))
    (list "can write text"
          "term.setCursorPos(1, 1)
           term.write(\"hello\")
           testlog.write({term.getCursorPos()})
           term.write(\" world\")
           testlog.write({term.getCursorPos()})"
          (list {1 6 2 1} {1 12 2 1}))
    (list "can blit text"
          "term.setCursorPos(1, 1)
           term.blit(\"hello\", \"fffff\", \"00000\")
           testlog.write({term.getCursorPos()})
           term.blit(\" world\", \"fffff\", \"00000\")
           testlog.write({term.getCursorPos()})"
          (list {1 6 2 1} {1 12 2 1}))))

(run-test-scripts! "A term" test-scripts)
