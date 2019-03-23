(import util (get-platform))
(import platforms/cc/runtime cc/runtime)
(import platforms/cc cc)
(import platforms/puc/runtime puc/runtime)
(import platforms/puc puc)

(defun start-runtime! (computer)
  (case (get-platform)
    [cc (cc/runtime/start! computer)]
    [puc (puc/runtime/start! computer)]
    [else (error! "suitable runtime not found")]))

(defun create-libs ()
  (case (get-platform)
    [cc (cc/create-libs)]
    [puc (puc/create-libs)]
    [else (error! "suitable libraries not found")]))
