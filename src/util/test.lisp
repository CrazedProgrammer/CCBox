(import test ())
(import computer)
(import spec (create-spec))

(define default-test-spec
  { :vfs-mounts '("tw:/:tests/testfs.json")
    :features "advanced testlog nil-term" })

(defmacro run-test-scripts! (name test-scripts)
  (let* [(test-script (gensym))
         (computer (gensym))]
   `(describe ,name
      (map (lambda (,test-script)
             (it (car ,test-script)
               (affirm (eq? (with (,computer (computer/create (create-spec
                                                               (merge default-test-spec { :bios (cadr ,test-script) }))))
                              (.> ,computer :testlog))
                            (caddr ,test-script)))))
           ,test-scripts))))
