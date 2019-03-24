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

(defun parse-http-response (all-headers)
  (let* [(status-code (tonumber (cadr (string/split all-headers " "))))
         (headers
           (assoc->struct
             (map (lambda (line)
                    (let* [(parts (string/split line "%: "))
                           (raw-name (car parts))
                           (value (cadr parts))]
                      (list (recapitalise-header-name raw-name) value)))
                  (cdr (string/split all-headers "\r\n")))))]
    (values-list status-code headers)))

(defun request (computer)
  (lambda (url post headers binary)
    (let* [(all-response-parts (string/split (run-program! (.. "curl -sLD - \"" url "\"")) "\r\n\r\n"))
           (n-redirect-headers (n (take-while (lambda (all-headers)
                                                (with ((status-code headers) (parse-http-response all-headers))
                                                  (or (= status-code 301) (= status-code 302))))
                                              all-response-parts
                                              1)))
           ((status-code headers) (parse-http-response (nth all-response-parts (+ n-redirect-headers 1))))
           (response (string/concat (drop all-response-parts (+ n-redirect-headers 1)) "\r\n\r\n"))
           (handle
             { :readAll (const response)
               :getResponseCode (const status-code)
               :getResponseHeaders (const headers)
               :close (const nil)})]
      ; TODO: implement other HTTP methods and request headers
      (event/queue! computer (list "http_success" url handle))
      true)))
