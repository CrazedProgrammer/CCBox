(import util (run-program! log!))
(import computer/event event)

(defun recapitalise-header-name (raw-name) :hidden
  ;; TODO: implement all special cases that CC expects to be handled
  ;; See https://github.com/netty/netty/blob/00afb19d7a37de21b35ce4f6cb3fa7f74809f2ab/codec-http/src/main/java/io/netty/handler/codec/http/HttpHeaders.java
  (concat
    (map (lambda (word)
           (.. (string/upper (string/sub word 1 1))
               (string/sub word 2 -1)))
         (string/split raw-name "%-"))
    "-"))

(defun request (computer)
  (lambda (url post headers binary)
    (let* [(all-response (run-program! (.. "curl -sD - \"" url "\"")))
           (all-headers (string/sub all-response 1 (- (string/find all-response "\r\n\r\n") 1)))
           (status-code (tonumber (cadr (string/split all-headers " "))))
           (headers
             (assoc->struct
               (map (lambda (line)
                      (let* [(parts (string/split line "%: "))
                             (raw-name (car parts))
                             (value (cadr parts))]
                        (list (recapitalise-header-name raw-name) value)))
                    (cdr (string/split all-headers "\r\n")))))
           (response (string/sub all-response (+ (string/find all-response "\r\n\r\n") 4) -1))
           (handle
             { :readAll (const response)
               :getResponseCode (const status-code)
               :getResponseHeaders (const headers)
               :close (const nil)})]
      ; TODO: implement other HTTP methods and request headers
      (event/queue! computer (list "http_success" url handle))
      true)))
