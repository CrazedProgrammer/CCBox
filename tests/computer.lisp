(import test ())
(import computer)
(import spec (create-spec))

(define test-spec
  { :bios "testlog.write(\"hello\")"
    :vfs-mounts '("tw:/:tests/testfs.json")
    :features "advanced testlog nil-term" })

(define test-scripts
  (list
    (list "can turn on"
          "testlog.write(\"hello world\")"
          (list "hello world"))
    (list "can write values of different types to the testlog"
          "testlog.write(\"test\")
           testlog.write(123)
           testlog.write(true)
           testlog.write(nil)
           testlog.write({100, 200})
           testlog.write({foo = 300, bar = 400})"
          (list "test" 123 true nil {1 100 2 200} { :foo 300 :bar 400 }))))

(describe "A computer"
  (map (lambda (test-script)
         (it (car test-script)
           (affirm (eq? (with (computer (computer/create (create-spec
                                                           (merge test-spec { :bios (cadr test-script) }))))
                          (.> computer :testlog))
                        (caddr test-script)))))
       test-scripts))
