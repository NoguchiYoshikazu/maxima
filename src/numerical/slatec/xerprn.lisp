;;; Compiled by f2cl version 2.0 beta Date: 2006/11/28 21:41:12 
;;; Using Lisp CMU Common Lisp Snapshot 2006-12 (19D)
;;; 
;;; Options: ((:prune-labels nil) (:auto-save t) (:relaxed-array-decls t)
;;;           (:coerce-assigns :as-needed) (:array-type ':simple-array)
;;;           (:array-slicing nil) (:declare-common nil)
;;;           (:float-format double-float))

(in-package :slatec)


(let* ((newlin "$$"))
  (declare (type (simple-array character (2)) newlin))
  (defun xerprn (prefix npref messg nwrap)
    (declare (type (f2cl-lib:integer4) nwrap npref)
             (type (simple-array character (*)) messg prefix))
    (prog ((iu (make-array 5 :element-type 'f2cl-lib:integer4)) (nunit 0)
           (cbuff
            (make-array '(148) :element-type 'character :initial-element #\ ))
           (idelta 0) (lpiece 0) (nextc 0) (lenmsg 0) (lwrap 0) (lpref 0) (i 0)
           (n 0))
      (declare (type (integer) n i lpref lwrap lenmsg nextc lpiece idelta)
               (type (simple-array f2cl-lib:integer4 (5)) iu)
               (type (f2cl-lib:integer4) nunit)
               (type (simple-array character (148)) cbuff))
      (multiple-value-bind (var-0 var-1)
          (xgetua iu nunit)
        (declare (ignore var-0))
        (setf nunit var-1))
      (setf n (f2cl-lib:i1mach 4))
      (f2cl-lib:fdo (i 1 (f2cl-lib:int-add i 1))
                    ((> i nunit) nil)
        (tagbody
          (if (= (f2cl-lib:fref iu (i) ((1 5))) 0)
              (setf (f2cl-lib:fref iu (i) ((1 5))) n))
         label10))
      (cond
        ((< npref 0)
         (setf lpref (f2cl-lib:len prefix)))
        (t
         (setf lpref npref)))
      (setf lpref
              (min (the f2cl-lib:integer4 16) (the f2cl-lib:integer4 lpref)))
      (if (/= lpref 0)
          (f2cl-lib:fset-string (f2cl-lib:fref-string cbuff (1 lpref)) prefix))
      (setf lwrap
              (max (the f2cl-lib:integer4 16)
                   (the f2cl-lib:integer4
                        (min (the f2cl-lib:integer4 132)
                             (the f2cl-lib:integer4 nwrap)))))
      (setf lenmsg (f2cl-lib:len messg))
      (setf n lenmsg)
      (f2cl-lib:fdo (i 1 (f2cl-lib:int-add i 1))
                    ((> i n) nil)
        (tagbody
          (if
           (f2cl-lib:fstring-/= (f2cl-lib:fref-string messg (lenmsg lenmsg))
                                " ")
           (go label30))
          (setf lenmsg (f2cl-lib:int-sub lenmsg 1))
         label20))
     label30
      (cond
        ((= lenmsg 0)
         (f2cl-lib:fset-string
          (f2cl-lib:fref-string cbuff ((+ lpref 1) (f2cl-lib:int-add lpref 1)))
          " ")
         (f2cl-lib:fdo (i 1 (f2cl-lib:int-add i 1))
                       ((> i nunit) nil)
           (tagbody
             (f2cl-lib:fformat (f2cl-lib:fref iu (i) ((1 5)))
                               (("~A~%"))
                               (f2cl-lib:fref-string cbuff
                                                     (1
                                                      (f2cl-lib:int-add lpref
                                                                        1))))
            label40))
         (go end_label)))
      (setf nextc 1)
     label50
      (setf lpiece
              (f2cl-lib:index (f2cl-lib:fref-string messg (nextc lenmsg))
                              newlin))
      (cond
        ((= lpiece 0)
         (tagbody
           (setf idelta 0)
           (setf lpiece
                   (min (the f2cl-lib:integer4 lwrap)
                        (the f2cl-lib:integer4
                             (f2cl-lib:int-sub (f2cl-lib:int-add lenmsg 1)
                                               nextc))))
           (cond
             ((< lpiece (f2cl-lib:int-add lenmsg 1 (f2cl-lib:int-sub nextc)))
              (f2cl-lib:fdo (i (f2cl-lib:int-add lpiece 1)
                             (f2cl-lib:int-add i (f2cl-lib:int-sub 1)))
                            ((> i 2) nil)
                (tagbody
                  (cond
                    ((f2cl-lib:fstring-=
                      (f2cl-lib:fref-string messg
                                            ((+ nextc i (f2cl-lib:int-sub 1))
                                             (f2cl-lib:int-add nextc
                                                               i
                                                               (f2cl-lib:int-sub
                                                                1))))
                      " ")
                     (setf lpiece (f2cl-lib:int-sub i 1))
                     (setf idelta 1)
                     (go label54)))
                 label52))))
          label54
           (f2cl-lib:fset-string
            (f2cl-lib:fref-string cbuff
                                  ((+ lpref 1)
                                   (f2cl-lib:int-add lpref lpiece)))
            (f2cl-lib:fref-string messg
                                  (nextc
                                   (f2cl-lib:int-sub
                                    (f2cl-lib:int-add nextc lpiece)
                                    1))))
           (setf nextc (f2cl-lib:int-add nextc lpiece idelta))))
        ((= lpiece 1)
         (setf nextc (f2cl-lib:int-add nextc 2))
         (go label50))
        ((> lpiece (f2cl-lib:int-add lwrap 1))
         (tagbody
           (setf idelta 0)
           (setf lpiece lwrap)
           (f2cl-lib:fdo (i (f2cl-lib:int-add lpiece 1)
                          (f2cl-lib:int-add i (f2cl-lib:int-sub 1)))
                         ((> i 2) nil)
             (tagbody
               (cond
                 ((f2cl-lib:fstring-=
                   (f2cl-lib:fref-string messg
                                         ((+ nextc i (f2cl-lib:int-sub 1))
                                          (f2cl-lib:int-add nextc
                                                            i
                                                            (f2cl-lib:int-sub
                                                             1))))
                   " ")
                  (setf lpiece (f2cl-lib:int-sub i 1))
                  (setf idelta 1)
                  (go label58)))
              label56))
          label58
           (f2cl-lib:fset-string
            (f2cl-lib:fref-string cbuff
                                  ((+ lpref 1)
                                   (f2cl-lib:int-add lpref lpiece)))
            (f2cl-lib:fref-string messg
                                  (nextc
                                   (f2cl-lib:int-sub
                                    (f2cl-lib:int-add nextc lpiece)
                                    1))))
           (setf nextc (f2cl-lib:int-add nextc lpiece idelta))))
        (t
         (setf lpiece (f2cl-lib:int-sub lpiece 1))
         (f2cl-lib:fset-string
          (f2cl-lib:fref-string cbuff
                                ((+ lpref 1) (f2cl-lib:int-add lpref lpiece)))
          (f2cl-lib:fref-string messg
                                (nextc
                                 (f2cl-lib:int-sub
                                  (f2cl-lib:int-add nextc lpiece)
                                  1))))
         (setf nextc (f2cl-lib:int-add nextc lpiece 2))))
      (f2cl-lib:fdo (i 1 (f2cl-lib:int-add i 1))
                    ((> i nunit) nil)
        (tagbody
          (f2cl-lib:fformat (f2cl-lib:fref iu (i) ((1 5)))
                            (("~A~%"))
                            (f2cl-lib:fref-string cbuff
                                                  (1
                                                   (f2cl-lib:int-add lpref
                                                                     lpiece))))
         label60))
      (if (<= nextc lenmsg) (go label50))
      (go end_label)
     end_label
      (return (values nil nil nil nil)))))

(in-package #:cl-user)
#+#.(cl:if (cl:find-package '#:f2cl) '(:and) '(:or))
(eval-when (:load-toplevel :compile-toplevel :execute)
  (setf (gethash 'fortran-to-lisp::xerprn
                 fortran-to-lisp::*f2cl-function-info*)
          (fortran-to-lisp::make-f2cl-finfo
           :arg-types '(#1=(simple-array character (*))
                        (fortran-to-lisp::integer4) #1#
                        (fortran-to-lisp::integer4))
           :return-values '(nil nil nil nil)
           :calls '(fortran-to-lisp::i1mach fortran-to-lisp::xgetua))))

