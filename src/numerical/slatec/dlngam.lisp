;;; Compiled by f2cl version 2.0 beta Date: 2006/11/28 21:41:12 
;;; Using Lisp CMU Common Lisp Snapshot 2006-12 (19D)
;;; 
;;; Options: ((:prune-labels nil) (:auto-save t) (:relaxed-array-decls t)
;;;           (:coerce-assigns :as-needed) (:array-type ':simple-array)
;;;           (:array-slicing nil) (:declare-common nil)
;;;           (:float-format double-float))

(in-package :slatec)


(let ((xmax 0.0)
      (dxrel 0.0)
      (sq2pil 0.9189385332046728)
      (sqpi2l 0.22579135264472744)
      (pi$ 3.141592653589793)
      (first$ nil))
  (declare (type f2cl-lib:logical first$)
           (type (double-float) pi$ sqpi2l sq2pil dxrel xmax))
  (setq first$ f2cl-lib:%true%)
  (defun dlngam (x)
    (declare (type (double-float) x))
    (prog ((sinpiy 0.0) (y 0.0) (temp 0.0) (dlngam 0.0) (log$ 0))
      (declare (type (integer) log$)
               (type (double-float) dlngam temp y sinpiy))
      (cond
        (first$
         (setf temp (/ 1.0 (f2cl-lib:flog (f2cl-lib:d1mach 2))))
         (setf xmax (* temp (f2cl-lib:d1mach 2)))
         (setf dxrel (f2cl-lib:fsqrt (f2cl-lib:d1mach 4)))))
      (setf first$ f2cl-lib:%false%)
      (setf y (abs x))
      (if (> y 10.0) (go label20))
      (setf dlngam (f2cl-lib:flog (abs (dgamma x))))
      (go end_label)
     label20
      (if (> y xmax)
          (xermsg "SLATEC" "DLNGAM" "ABS(X) SO BIG DLNGAM OVERFLOWS" 2 2))
      (if (> x 0.0)
          (setf dlngam
                  (+ (- (+ sq2pil (* (- x 0.5) (f2cl-lib:flog x))) x)
                     (d9lgmc y))))
      (if (> x 0.0) (go end_label))
      (setf sinpiy (abs (sin (* pi$ y))))
      (if (= sinpiy 0.0)
          (xermsg "SLATEC" "DLNGAM" "X IS A NEGATIVE INTEGER" 3 2))
      (if (< (abs (/ (- x (f2cl-lib:aint (- x 0.5))) x)) dxrel)
          (xermsg "SLATEC" "DLNGAM"
           "ANSWER LT HALF PRECISION BECAUSE X TOO NEAR NEGATIVE INTEGER" 1 1))
      (setf dlngam
              (- (+ sqpi2l (* (- x 0.5) (f2cl-lib:flog y)))
                 x
                 (f2cl-lib:flog sinpiy)
                 (d9lgmc y)))
      (go end_label)
     end_label
      (return (values dlngam nil)))))

(in-package #:cl-user)
#+#.(cl:if (cl:find-package '#:f2cl) '(:and) '(:or))
(eval-when (:load-toplevel :compile-toplevel :execute)
  (setf (gethash 'fortran-to-lisp::dlngam
                 fortran-to-lisp::*f2cl-function-info*)
          (fortran-to-lisp::make-f2cl-finfo :arg-types '((double-float))
                                            :return-values '(nil)
                                            :calls '(fortran-to-lisp::d9lgmc
                                                     fortran-to-lisp::xermsg
                                                     fortran-to-lisp::dgamma
                                                     fortran-to-lisp::d1mach))))

