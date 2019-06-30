(import util/test (run-test-scripts!))

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

(run-test-scripts! "A computer" test-scripts)
