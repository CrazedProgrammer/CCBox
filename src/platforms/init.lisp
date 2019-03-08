(import config (args))
(import util (get-platform))
(import platforms/cc/runtime cc/runtime)
(import platforms/cc/term cc/term)
(import platforms/puc/runtime puc/runtime)
(import platforms/puc/term puc/term)

(defun start-runtime! (computer)
  (case (get-platform)
    [cc (cc/runtime/start! computer)]
    [puc (puc/runtime/start! computer)]
    [else (error! "suitable runtime not found")]))

(defun create-native-term ()
  (case (get-platform)
    [cc (cc/term/create)]
    [puc (puc/term/create)]
    [else (error! "suitable terminal not found")]))
