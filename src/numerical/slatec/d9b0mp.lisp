;;; Compiled by f2cl version 2.0 beta Date: 2006/11/28 21:41:12 
;;; Using Lisp CMU Common Lisp Snapshot 2006-12 (19D)
;;; 
;;; Options: ((:prune-labels nil) (:auto-save t) (:relaxed-array-decls t)
;;;           (:coerce-assigns :as-needed) (:array-type ':simple-array)
;;;           (:array-slicing nil) (:declare-common nil)
;;;           (:float-format double-float))

(in-package :slatec)


(let ((nbm0 0)
      (nbt02 0)
      (nbm02 0)
      (nbth0 0)
      (xmax 0.0)
      (bm0cs
       (make-array 37
                   :element-type 'double-float
                   :initial-contents '(0.09211656246827743
                                       -0.0010505909972719051
                                       1.4701598407687597e-5
                                       -5.058557606038554e-7
                                       2.7872545386324443e-8
                                       -2.062363611780915e-9
                                       1.8702143131388797e-10
                                       -1.9693309711356362e-11
                                       2.3259737939992754e-12
                                       -3.0095203449382503e-13
                                       4.1945213338506693e-14
                                       -6.219449312188446e-15
                                       9.71826041133607e-16
                                       -1.5884785857010752e-16
                                       2.7000721936713088e-17
                                       -4.7500923652340086e-18
                                       8.615128162604371e-19
                                       -1.6056086869561448e-19
                                       3.066513987314483e-20
                                       -5.987764223193956e-21
                                       1.1929712537482484e-21
                                       -2.4209691420448057e-22
                                       4.9967517605106164e-23
                                       -1.0474936393511585e-23
                                       2.2277868437974682e-24
                                       -4.801813239398163e-25
                                       1.04796272347096e-25
                                       -2.3138581656786152e-26
                                       5.164823088462674e-27
                                       -1.1646911918500655e-27
                                       2.651788486043319e-28
                                       -6.092559503825728e-29
                                       1.4118046861442593e-29
                                       -3.298094961231737e-30
                                       7.763931143074065e-31
                                       -1.8410313436614585e-31
                                       4.395880138594311e-32)))
      (bth0cs
       (make-array 44
                   :element-type 'double-float
                   :initial-contents '(-0.24901780862128936
                                       4.855029960962375e-4
                                       -5.4511837345017206e-6
                                       1.3558673059405963e-7
                                       -5.5691398902227624e-9
                                       3.2609031824994337e-10
                                       -2.491880786246134e-11
                                       2.344937742088252e-12
                                       -2.609653444431039e-13
                                       3.3353140420097393e-14
                                       -4.789000044057268e-15
                                       7.595617843619222e-16
                                       -1.3131556016891442e-16
                                       2.4483618345240857e-17
                                       -4.880572981061878e-18
                                       1.0327285029786316e-18
                                       -2.3057633815057217e-19
                                       5.404444300189269e-20
                                       -1.3240695194366572e-20
                                       3.378079562137197e-21
                                       -8.945762915711178e-22
                                       2.4519906889219317e-22
                                       -6.938842287686632e-23
                                       2.022827871489014e-23
                                       -6.062850000233549e-24
                                       1.8649748964037634e-24
                                       -5.878373238484989e-25
                                       1.8958591447999562e-25
                                       -6.248197937225886e-26
                                       2.1017901684551025e-26
                                       -7.208430093520926e-27
                                       2.5181363892474242e-27
                                       -8.951804225878578e-28
                                       3.23572374797623e-28
                                       -1.1883010519855353e-28
                                       4.4306286907358106e-29
                                       -1.676100964883483e-29
                                       6.429294692120746e-30
                                       -2.499226116697865e-30
                                       9.839979429952196e-31
                                       -3.9220375242408017e-31
                                       1.5818107030056521e-31
                                       -6.452550614489072e-32
                                       2.6611111369199356e-32)))
      (bm02cs
       (make-array 40
                   :element-type 'double-float
                   :initial-contents '(0.09500415145228382
                                       -3.801864682365671e-4
                                       2.258339301031481e-6
                                       -3.895725802372229e-8
                                       1.2468864165120817e-9
                                       -6.065949022102504e-11
                                       4.008461651421747e-12
                                       -3.3509981833980945e-13
                                       3.3771197165174173e-14
                                       -3.964585901635013e-15
                                       5.286111503883857e-16
                                       -7.852519083450852e-17
                                       1.2803005733866823e-17
                                       -2.26399629639143e-18
                                       4.3004969296567905e-19
                                       -8.705749805132587e-20
                                       1.8658627139620952e-20
                                       -4.210482486093065e-21
                                       9.9566769642284e-22
                                       -2.457357442805313e-22
                                       6.307692160762032e-23
                                       -1.6787736914407402e-23
                                       4.6202590646739044e-24
                                       -1.3117822668603088e-24
                                       3.834087564116303e-25
                                       -1.1514593240777412e-25
                                       3.547210007523339e-26
                                       -1.1192183858150046e-26
                                       3.611879427629838e-27
                                       -1.1906877659133332e-27
                                       4.005094059403968e-28
                                       -1.3731694224522124e-28
                                       4.7941990887425316e-29
                                       -1.7029656276241095e-29
                                       6.14951242893633e-30
                                       -2.2557668965818283e-30
                                       8.3997075092943e-31
                                       -3.1729975955626022e-31
                                       1.2152052988812985e-31
                                       -4.7158527497544386e-32)))
      (bt02cs
       (make-array 39
                   :element-type 'double-float
                   :initial-contents '(-0.24548295213424598
                                       0.0012544121039084616
                                       -3.1253950414871526e-5
                                       1.4709778249940832e-6
                                       -9.954348893795004e-8
                                       8.549316673320304e-9
                                       -8.698975952655434e-10
                                       1.0052099533559791e-10
                                       -1.2828230601708893e-11
                                       1.7731700781805131e-12
                                       -2.617457456948558e-13
                                       4.082835138997206e-14
                                       -6.675166823974272e-15
                                       1.136576139307163e-15
                                       -2.005118962064716e-16
                                       3.649797879476627e-17
                                       -6.8309637564582306e-18
                                       1.3107583145670756e-18
                                       -2.5723363101850606e-19
                                       5.152165744186396e-20
                                       -1.0513017563758802e-20
                                       2.1820381991194814e-21
                                       -4.600470121036216e-22
                                       9.840700692546682e-23
                                       -2.1334038035728374e-23
                                       4.683103642397336e-24
                                       -1.0400213691985747e-24
                                       2.334910567730151e-25
                                       -5.295682532331862e-26
                                       1.2126341952959756e-26
                                       -2.801889708228943e-27
                                       6.529267898701287e-28
                                       -1.5337980061873346e-28
                                       3.6305884306364537e-29
                                       -8.656075571362912e-30
                                       2.0779909972536286e-30
                                       -5.021117022141722e-31
                                       1.2208360279441715e-31
                                       -2.986005626703991e-32)))
      (pi4 0.7853981633974483)
      (first$ nil))
  (declare (type f2cl-lib:logical first$)
           (type (simple-array double-float (39)) bt02cs)
           (type (simple-array double-float (40)) bm02cs)
           (type (simple-array double-float (44)) bth0cs)
           (type (simple-array double-float (37)) bm0cs)
           (type (double-float) pi4 xmax)
           (type (integer) nbth0 nbm02 nbt02 nbm0))
  (setq first$ f2cl-lib:%true%)
  (defun d9b0mp (x ampl theta)
    (declare (type (double-float) theta ampl x))
    (prog ((z 0.0) (eta 0.0f0))
      (declare (type (single-float) eta) (type (double-float) z))
      (cond
        (first$
         (setf eta (* 0.1f0 (f2cl-lib:freal (f2cl-lib:d1mach 3))))
         (setf nbm0 (initds bm0cs 37 eta))
         (setf nbt02 (initds bt02cs 39 eta))
         (setf nbm02 (initds bm02cs 40 eta))
         (setf nbth0 (initds bth0cs 44 eta))
         (setf xmax (/ 1.0 (f2cl-lib:d1mach 4)))))
      (setf first$ f2cl-lib:%false%)
      (if (< x 4.0) (xermsg "SLATEC" "D9B0MP" "X MUST BE GE 4" 1 2))
      (if (> x 8.0) (go label20))
      (setf z (/ (- (/ 128.0 (* x x)) 5.0) 3.0))
      (setf ampl (/ (+ 0.75 (dcsevl z bm0cs nbm0)) (f2cl-lib:fsqrt x)))
      (setf theta (+ (- x pi4) (/ (dcsevl z bt02cs nbt02) x)))
      (go end_label)
     label20
      (if (> x xmax)
          (xermsg "SLATEC" "D9B0MP" "NO PRECISION BECAUSE X IS BIG" 2 2))
      (setf z (- (/ 128.0 (* x x)) 1.0))
      (setf ampl (/ (+ 0.75 (dcsevl z bm02cs nbm02)) (f2cl-lib:fsqrt x)))
      (setf theta (+ (- x pi4) (/ (dcsevl z bth0cs nbth0) x)))
      (go end_label)
     end_label
      (return (values nil ampl theta)))))

(in-package #:cl-user)
#+#.(cl:if (cl:find-package '#:f2cl) '(:and) '(:or))
(eval-when (:load-toplevel :compile-toplevel :execute)
  (setf (gethash 'fortran-to-lisp::d9b0mp
                 fortran-to-lisp::*f2cl-function-info*)
          (fortran-to-lisp::make-f2cl-finfo
           :arg-types '((double-float) (double-float) (double-float))
           :return-values '(nil fortran-to-lisp::ampl fortran-to-lisp::theta)
           :calls '(fortran-to-lisp::dcsevl fortran-to-lisp::xermsg
                    fortran-to-lisp::initds fortran-to-lisp::d1mach))))

