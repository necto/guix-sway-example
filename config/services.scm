(define-module (config services)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages linux)
  #:use-module (guix gexp)
  #:export (%powertop-service))

;; Create a "one-shot" service that runs powertop --auto-tune on boot.
(define %powertop-service
  (simple-service 'powertop shepherd-root-service-type
                  (list (shepherd-service
                         (provision '(powertop))
                         (requirement '(user-processes))
                         (start #~(lambda ()
                                    (invoke
                                     #$(file-append powertop "/sbin/powertop")
                                     "--auto-tune")))
                         (one-shot? #t)))))

