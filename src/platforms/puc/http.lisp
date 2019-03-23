(import util (run-program! log!))
(import computer/event event)

(defun request (computer)
  (lambda (url post headers binary)
    (let* [(all-response (run-program! (.. "curl -sD - \"" url "\"")))
           (all-headers (string/sub all-response 1 (- (string/find all-response "\r\n\r\n") 1)))
           (status-code (tonumber (cadr (string/split all-headers " "))))
           (headers
             (assoc->struct
               (map (cut string/split <> "%: ")
                    (cdr (string/split all-headers "\r\n")))))
           (response (string/sub all-response (+ (string/find all-response "\r\n\r\n") 4) -1))
           (handle
             { :readAll (const response)
               :getResponseCode (const status-code)
               :getResponseHeaders (const headers) })]
      ; TODO: implement other HTTP methods and request headers
      (event/queue! computer (list "http_success" url handle))
      true)))
