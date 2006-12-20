;;; Compiled by f2cl version 2.0 beta Date: 2006/11/28 21:41:12 
;;; Using Lisp CMU Common Lisp Snapshot 2006-12 (19D)
;;; 
;;; Options: ((:prune-labels nil) (:auto-save t) (:relaxed-array-decls t)
;;;           (:coerce-assigns :as-needed) (:array-type ':array)
;;;           (:array-slicing t) (:declare-common nil)
;;;           (:float-format double-float))

(in-package :slatec)


(let ((zeror 0.0) (zeroi 0.0) (coner 1.0) (pi$ 3.141592653589793))
  (declare (type (double-float) pi$ coner zeroi zeror))
  (defun zunk1 (zr zi fnu kode mr n yr yi nz tol elim alim)
    (declare (type (array double-float (*)) yi yr)
             (type (f2cl-lib:integer4) nz n mr kode)
             (type (double-float) alim elim tol fnu zi zr))
    (f2cl-lib:with-multi-array-data
        ((yr double-float yr-%data% yr-%offset%)
         (yi double-float yi-%data% yi-%offset%))
      (prog ((bry (make-array 3 :element-type 'double-float))
             (init (make-array 2 :element-type 'f2cl-lib:integer4))
             (sumr (make-array 2 :element-type 'double-float))
             (sumi (make-array 2 :element-type 'double-float))
             (zeta1r (make-array 2 :element-type 'double-float))
             (zeta1i (make-array 2 :element-type 'double-float))
             (zeta2r (make-array 2 :element-type 'double-float))
             (zeta2i (make-array 2 :element-type 'double-float))
             (cyr (make-array 2 :element-type 'double-float))
             (cyi (make-array 2 :element-type 'double-float))
             (cwrkr (make-array 48 :element-type 'double-float))
             (cwrki (make-array 48 :element-type 'double-float))
             (cssr (make-array 3 :element-type 'double-float))
             (csrr (make-array 3 :element-type 'double-float))
             (phir (make-array 2 :element-type 'double-float))
             (phii (make-array 2 :element-type 'double-float)) (i 0) (ib 0)
             (iflag 0) (ifn 0) (il 0) (inu 0) (iuf 0) (k 0) (kdflg 0) (kflag 0)
             (kk 0) (nw 0) (initd 0) (ic 0) (ipard 0) (j 0) (m 0) (ang 0.0)
             (aphi 0.0) (asc 0.0) (ascle 0.0) (cki 0.0) (ckr 0.0) (crsc 0.0)
             (cscl 0.0) (csgni 0.0) (cspni 0.0) (cspnr 0.0) (csr 0.0) (c1i 0.0)
             (c1r 0.0) (c2i 0.0) (c2m 0.0) (c2r 0.0) (fmr 0.0) (fn 0.0)
             (fnf 0.0) (phidi 0.0) (phidr 0.0) (rast 0.0) (razr 0.0) (rs1 0.0)
             (rzi 0.0) (rzr 0.0) (sgn 0.0) (sti 0.0) (str 0.0) (sumdi 0.0)
             (sumdr 0.0) (s1i 0.0) (s1r 0.0) (s2i 0.0) (s2r 0.0) (zet1di 0.0)
             (zet1dr 0.0) (zet2di 0.0) (zet2dr 0.0) (zri 0.0) (zrr 0.0))
        (declare (type (array double-float (2)) zeta2r zeta2i zeta1r zeta1i
                                                sumr sumi phir phii cyr cyi)
                 (type (array double-float (48)) cwrkr cwrki)
                 (type (array double-float (3)) cssr csrr bry)
                 (type (double-float) zrr zri zet2dr zet2di zet1dr zet1di s2r
                                      s2i s1r s1i sumdr sumdi str sti sgn rzr
                                      rzi rs1 razr rast phidr phidi fnf fn fmr
                                      c2r c2m c2i c1r c1i csr cspnr cspni csgni
                                      cscl crsc ckr cki ascle asc aphi ang)
                 (type (array f2cl-lib:integer4 (2)) init)
                 (type (f2cl-lib:integer4) m j ipard ic initd nw kk kflag kdflg
                                           k iuf inu il ifn iflag ib i))
        (setf kdflg 1)
        (setf nz 0)
        (setf cscl (/ 1.0 tol))
        (setf crsc tol)
        (setf (f2cl-lib:fref cssr (1) ((1 3))) cscl)
        (setf (f2cl-lib:fref cssr (2) ((1 3))) coner)
        (setf (f2cl-lib:fref cssr (3) ((1 3))) crsc)
        (setf (f2cl-lib:fref csrr (1) ((1 3))) crsc)
        (setf (f2cl-lib:fref csrr (2) ((1 3))) coner)
        (setf (f2cl-lib:fref csrr (3) ((1 3))) cscl)
        (setf (f2cl-lib:fref bry (1) ((1 3)))
                (/ (* 1000.0 (f2cl-lib:d1mach 1)) tol))
        (setf (f2cl-lib:fref bry (2) ((1 3)))
                (/ 1.0 (f2cl-lib:fref bry (1) ((1 3)))))
        (setf (f2cl-lib:fref bry (3) ((1 3))) (f2cl-lib:d1mach 2))
        (setf zrr zr)
        (setf zri zi)
        (if (>= zr 0.0) (go label10))
        (setf zrr (- zr))
        (setf zri (- zi))
       label10
        (setf j 2)
        (f2cl-lib:fdo (i 1 (f2cl-lib:int-add i 1))
                      ((> i n) nil)
          (tagbody
            (setf j (f2cl-lib:int-sub 3 j))
            (setf fn (+ fnu (f2cl-lib:int-sub i 1)))
            (setf (f2cl-lib:fref init (j) ((1 2))) 0)
            (multiple-value-bind
                  (var-0 var-1 var-2 var-3 var-4 var-5 var-6 var-7 var-8 var-9
                   var-10 var-11 var-12 var-13 var-14 var-15 var-16)
                (zunik zrr zri fn 2 0 tol (f2cl-lib:fref init (j) ((1 2)))
                 (f2cl-lib:fref phir (j) ((1 2)))
                 (f2cl-lib:fref phii (j) ((1 2)))
                 (f2cl-lib:fref zeta1r (j) ((1 2)))
                 (f2cl-lib:fref zeta1i (j) ((1 2)))
                 (f2cl-lib:fref zeta2r (j) ((1 2)))
                 (f2cl-lib:fref zeta2i (j) ((1 2)))
                 (f2cl-lib:fref sumr (j) ((1 2)))
                 (f2cl-lib:fref sumi (j) ((1 2)))
                 (f2cl-lib:array-slice cwrkr double-float (1 j) ((1 16) (1 3)))
                 (f2cl-lib:array-slice cwrki
                                       double-float
                                       (1 j)
                                       ((1 16) (1 3))))
              (declare (ignore var-0 var-1 var-2 var-3 var-4 var-5 var-15
                               var-16))
              (setf (f2cl-lib:fref init (j) ((1 2))) var-6)
              (setf (f2cl-lib:fref phir (j) ((1 2))) var-7)
              (setf (f2cl-lib:fref phii (j) ((1 2))) var-8)
              (setf (f2cl-lib:fref zeta1r (j) ((1 2))) var-9)
              (setf (f2cl-lib:fref zeta1i (j) ((1 2))) var-10)
              (setf (f2cl-lib:fref zeta2r (j) ((1 2))) var-11)
              (setf (f2cl-lib:fref zeta2i (j) ((1 2))) var-12)
              (setf (f2cl-lib:fref sumr (j) ((1 2))) var-13)
              (setf (f2cl-lib:fref sumi (j) ((1 2))) var-14))
            (if (= kode 1) (go label20))
            (setf str (+ zrr (f2cl-lib:fref zeta2r (j) ((1 2)))))
            (setf sti (+ zri (f2cl-lib:fref zeta2i (j) ((1 2)))))
            (setf rast (coerce (realpart (/ fn (zabs str sti))) 'double-float))
            (setf str (* str rast rast))
            (setf sti (* (- sti) rast rast))
            (setf s1r (- (f2cl-lib:fref zeta1r (j) ((1 2))) str))
            (setf s1i (- (f2cl-lib:fref zeta1i (j) ((1 2))) sti))
            (go label30)
           label20
            (setf s1r
                    (- (f2cl-lib:fref zeta1r (j) ((1 2)))
                       (f2cl-lib:fref zeta2r (j) ((1 2)))))
            (setf s1i
                    (- (f2cl-lib:fref zeta1i (j) ((1 2)))
                       (f2cl-lib:fref zeta2i (j) ((1 2)))))
           label30
            (setf rs1 s1r)
            (if (> (abs rs1) elim) (go label60))
            (if (= kdflg 1) (setf kflag 2))
            (if (< (abs rs1) alim) (go label40))
            (setf aphi
                    (coerce
                     (realpart
                      (zabs (f2cl-lib:fref phir (j) ((1 2)))
                       (f2cl-lib:fref phii (j) ((1 2)))))
                     'double-float))
            (setf rs1 (+ rs1 (f2cl-lib:flog aphi)))
            (if (> (abs rs1) elim) (go label60))
            (if (= kdflg 1) (setf kflag 1))
            (if (< rs1 0.0) (go label40))
            (if (= kdflg 1) (setf kflag 3))
           label40
            (setf s2r
                    (-
                     (* (f2cl-lib:fref phir (j) ((1 2)))
                        (f2cl-lib:fref sumr (j) ((1 2))))
                     (* (f2cl-lib:fref phii (j) ((1 2)))
                        (f2cl-lib:fref sumi (j) ((1 2))))))
            (setf s2i
                    (+
                     (* (f2cl-lib:fref phir (j) ((1 2)))
                        (f2cl-lib:fref sumi (j) ((1 2))))
                     (* (f2cl-lib:fref phii (j) ((1 2)))
                        (f2cl-lib:fref sumr (j) ((1 2))))))
            (setf str (* (exp s1r) (f2cl-lib:fref cssr (kflag) ((1 3)))))
            (setf s1r (* str (cos s1i)))
            (setf s1i (* str (sin s1i)))
            (setf str (- (* s2r s1r) (* s2i s1i)))
            (setf s2i (+ (* s1r s2i) (* s2r s1i)))
            (setf s2r str)
            (if (/= kflag 1) (go label50))
            (multiple-value-bind (var-0 var-1 var-2 var-3 var-4)
                (zuchk s2r s2i nw (f2cl-lib:fref bry (1) ((1 3))) tol)
              (declare (ignore var-0 var-1 var-3 var-4))
              (setf nw var-2))
            (if (/= nw 0) (go label60))
           label50
            (setf (f2cl-lib:fref cyr (kdflg) ((1 2))) s2r)
            (setf (f2cl-lib:fref cyi (kdflg) ((1 2))) s2i)
            (setf (f2cl-lib:fref yr-%data% (i) ((1 n)) yr-%offset%)
                    (* s2r (f2cl-lib:fref csrr (kflag) ((1 3)))))
            (setf (f2cl-lib:fref yi-%data% (i) ((1 n)) yi-%offset%)
                    (* s2i (f2cl-lib:fref csrr (kflag) ((1 3)))))
            (if (= kdflg 2) (go label75))
            (setf kdflg 2)
            (go label70)
           label60
            (if (> rs1 0.0) (go label300))
            (if (< zr 0.0) (go label300))
            (setf kdflg 1)
            (setf (f2cl-lib:fref yr-%data% (i) ((1 n)) yr-%offset%) zeror)
            (setf (f2cl-lib:fref yi-%data% (i) ((1 n)) yi-%offset%) zeroi)
            (setf nz (f2cl-lib:int-add nz 1))
            (if (= i 1) (go label70))
            (if
             (and
              (=
               (f2cl-lib:fref yr-%data%
                              ((f2cl-lib:int-sub i 1))
                              ((1 n))
                              yr-%offset%)
               zeror)
              (=
               (f2cl-lib:fref yi-%data%
                              ((f2cl-lib:int-sub i 1))
                              ((1 n))
                              yi-%offset%)
               zeroi))
             (go label70))
            (setf (f2cl-lib:fref yr-%data%
                                 ((f2cl-lib:int-sub i 1))
                                 ((1 n))
                                 yr-%offset%)
                    zeror)
            (setf (f2cl-lib:fref yi-%data%
                                 ((f2cl-lib:int-sub i 1))
                                 ((1 n))
                                 yi-%offset%)
                    zeroi)
            (setf nz (f2cl-lib:int-add nz 1))
           label70))
        (setf i n)
       label75
        (setf razr (coerce (realpart (/ 1.0 (zabs zrr zri))) 'double-float))
        (setf str (* zrr razr))
        (setf sti (* (- zri) razr))
        (setf rzr (* (+ str str) razr))
        (setf rzi (* (+ sti sti) razr))
        (setf ckr (* fn rzr))
        (setf cki (* fn rzi))
        (setf ib (f2cl-lib:int-add i 1))
        (if (< n ib) (go label160))
        (setf fn (+ fnu (f2cl-lib:int-sub n 1)))
        (setf ipard 1)
        (if (/= mr 0) (setf ipard 0))
        (setf initd 0)
        (multiple-value-bind
              (var-0 var-1 var-2 var-3 var-4 var-5 var-6 var-7 var-8 var-9
               var-10 var-11 var-12 var-13 var-14 var-15 var-16)
            (zunik zrr zri fn 2 ipard tol initd phidr phidi zet1dr zet1di
             zet2dr zet2di sumdr sumdi
             (f2cl-lib:array-slice cwrkr double-float (1 3) ((1 16) (1 3)))
             (f2cl-lib:array-slice cwrki double-float (1 3) ((1 16) (1 3))))
          (declare (ignore var-0 var-1 var-2 var-3 var-4 var-5 var-15 var-16))
          (setf initd var-6)
          (setf phidr var-7)
          (setf phidi var-8)
          (setf zet1dr var-9)
          (setf zet1di var-10)
          (setf zet2dr var-11)
          (setf zet2di var-12)
          (setf sumdr var-13)
          (setf sumdi var-14))
        (if (= kode 1) (go label80))
        (setf str (+ zrr zet2dr))
        (setf sti (+ zri zet2di))
        (setf rast (coerce (realpart (/ fn (zabs str sti))) 'double-float))
        (setf str (* str rast rast))
        (setf sti (* (- sti) rast rast))
        (setf s1r (- zet1dr str))
        (setf s1i (- zet1di sti))
        (go label90)
       label80
        (setf s1r (- zet1dr zet2dr))
        (setf s1i (- zet1di zet2di))
       label90
        (setf rs1 s1r)
        (if (> (abs rs1) elim) (go label95))
        (if (< (abs rs1) alim) (go label100))
        (setf aphi (coerce (realpart (zabs phidr phidi)) 'double-float))
        (setf rs1 (+ rs1 (f2cl-lib:flog aphi)))
        (if (< (abs rs1) elim) (go label100))
       label95
        (if (> (abs rs1) 0.0) (go label300))
        (if (< zr 0.0) (go label300))
        (setf nz n)
        (f2cl-lib:fdo (i 1 (f2cl-lib:int-add i 1))
                      ((> i n) nil)
          (tagbody
            (setf (f2cl-lib:fref yr-%data% (i) ((1 n)) yr-%offset%) zeror)
            (setf (f2cl-lib:fref yi-%data% (i) ((1 n)) yi-%offset%) zeroi)
           label96))
        (go end_label)
       label100
        (setf s1r (f2cl-lib:fref cyr (1) ((1 2))))
        (setf s1i (f2cl-lib:fref cyi (1) ((1 2))))
        (setf s2r (f2cl-lib:fref cyr (2) ((1 2))))
        (setf s2i (f2cl-lib:fref cyi (2) ((1 2))))
        (setf c1r (f2cl-lib:fref csrr (kflag) ((1 3))))
        (setf ascle (f2cl-lib:fref bry (kflag) ((1 3))))
        (f2cl-lib:fdo (i ib (f2cl-lib:int-add i 1))
                      ((> i n) nil)
          (tagbody
            (setf c2r s2r)
            (setf c2i s2i)
            (setf s2r (+ (- (* ckr c2r) (* cki c2i)) s1r))
            (setf s2i (+ (* ckr c2i) (* cki c2r) s1i))
            (setf s1r c2r)
            (setf s1i c2i)
            (setf ckr (+ ckr rzr))
            (setf cki (+ cki rzi))
            (setf c2r (* s2r c1r))
            (setf c2i (* s2i c1r))
            (setf (f2cl-lib:fref yr-%data% (i) ((1 n)) yr-%offset%) c2r)
            (setf (f2cl-lib:fref yi-%data% (i) ((1 n)) yi-%offset%) c2i)
            (if (>= kflag 3) (go label120))
            (setf str (abs c2r))
            (setf sti (abs c2i))
            (setf c2m (max str sti))
            (if (<= c2m ascle) (go label120))
            (setf kflag (f2cl-lib:int-add kflag 1))
            (setf ascle (f2cl-lib:fref bry (kflag) ((1 3))))
            (setf s1r (* s1r c1r))
            (setf s1i (* s1i c1r))
            (setf s2r c2r)
            (setf s2i c2i)
            (setf s1r (* s1r (f2cl-lib:fref cssr (kflag) ((1 3)))))
            (setf s1i (* s1i (f2cl-lib:fref cssr (kflag) ((1 3)))))
            (setf s2r (* s2r (f2cl-lib:fref cssr (kflag) ((1 3)))))
            (setf s2i (* s2i (f2cl-lib:fref cssr (kflag) ((1 3)))))
            (setf c1r (f2cl-lib:fref csrr (kflag) ((1 3))))
           label120))
       label160
        (if (= mr 0) (go end_label))
        (setf nz 0)
        (setf fmr (coerce (the f2cl-lib:integer4 mr) 'double-float))
        (setf sgn (coerce (- (f2cl-lib:dsign pi$ fmr)) 'double-float))
        (setf csgni sgn)
        (setf inu (f2cl-lib:int fnu))
        (setf fnf (- fnu inu))
        (setf ifn (f2cl-lib:int-sub (f2cl-lib:int-add inu n) 1))
        (setf ang (* fnf sgn))
        (setf cspnr (cos ang))
        (setf cspni (sin ang))
        (if (= (mod ifn 2) 0) (go label170))
        (setf cspnr (- cspnr))
        (setf cspni (- cspni))
       label170
        (setf asc (f2cl-lib:fref bry (1) ((1 3))))
        (setf iuf 0)
        (setf kk n)
        (setf kdflg 1)
        (setf ib (f2cl-lib:int-sub ib 1))
        (setf ic (f2cl-lib:int-sub ib 1))
        (f2cl-lib:fdo (k 1 (f2cl-lib:int-add k 1))
                      ((> k n) nil)
          (tagbody
            (setf fn (+ fnu (f2cl-lib:int-sub kk 1)))
            (setf m 3)
            (if (> n 2) (go label175))
           label172
            (setf initd (f2cl-lib:fref init (j) ((1 2))))
            (setf phidr (f2cl-lib:fref phir (j) ((1 2))))
            (setf phidi (f2cl-lib:fref phii (j) ((1 2))))
            (setf zet1dr (f2cl-lib:fref zeta1r (j) ((1 2))))
            (setf zet1di (f2cl-lib:fref zeta1i (j) ((1 2))))
            (setf zet2dr (f2cl-lib:fref zeta2r (j) ((1 2))))
            (setf zet2di (f2cl-lib:fref zeta2i (j) ((1 2))))
            (setf sumdr (f2cl-lib:fref sumr (j) ((1 2))))
            (setf sumdi (f2cl-lib:fref sumi (j) ((1 2))))
            (setf m j)
            (setf j (f2cl-lib:int-sub 3 j))
            (go label180)
           label175
            (if (and (= kk n) (< ib n)) (go label180))
            (if (or (= kk ib) (= kk ic)) (go label172))
            (setf initd 0)
           label180
            (multiple-value-bind
                  (var-0 var-1 var-2 var-3 var-4 var-5 var-6 var-7 var-8 var-9
                   var-10 var-11 var-12 var-13 var-14 var-15 var-16)
                (zunik zrr zri fn 1 0 tol initd phidr phidi zet1dr zet1di
                 zet2dr zet2di sumdr sumdi
                 (f2cl-lib:array-slice cwrkr double-float (1 m) ((1 16) (1 3)))
                 (f2cl-lib:array-slice cwrki
                                       double-float
                                       (1 m)
                                       ((1 16) (1 3))))
              (declare (ignore var-0 var-1 var-2 var-3 var-4 var-5 var-15
                               var-16))
              (setf initd var-6)
              (setf phidr var-7)
              (setf phidi var-8)
              (setf zet1dr var-9)
              (setf zet1di var-10)
              (setf zet2dr var-11)
              (setf zet2di var-12)
              (setf sumdr var-13)
              (setf sumdi var-14))
            (if (= kode 1) (go label200))
            (setf str (+ zrr zet2dr))
            (setf sti (+ zri zet2di))
            (setf rast (coerce (realpart (/ fn (zabs str sti))) 'double-float))
            (setf str (* str rast rast))
            (setf sti (* (- sti) rast rast))
            (setf s1r (- str zet1dr))
            (setf s1i (- sti zet1di))
            (go label210)
           label200
            (setf s1r (- zet2dr zet1dr))
            (setf s1i (- zet2di zet1di))
           label210
            (setf rs1 s1r)
            (if (> (abs rs1) elim) (go label260))
            (if (= kdflg 1) (setf iflag 2))
            (if (< (abs rs1) alim) (go label220))
            (setf aphi (coerce (realpart (zabs phidr phidi)) 'double-float))
            (setf rs1 (+ rs1 (f2cl-lib:flog aphi)))
            (if (> (abs rs1) elim) (go label260))
            (if (= kdflg 1) (setf iflag 1))
            (if (< rs1 0.0) (go label220))
            (if (= kdflg 1) (setf iflag 3))
           label220
            (setf str (- (* phidr sumdr) (* phidi sumdi)))
            (setf sti (+ (* phidr sumdi) (* phidi sumdr)))
            (setf s2r (* (- csgni) sti))
            (setf s2i (* csgni str))
            (setf str (* (exp s1r) (f2cl-lib:fref cssr (iflag) ((1 3)))))
            (setf s1r (* str (cos s1i)))
            (setf s1i (* str (sin s1i)))
            (setf str (- (* s2r s1r) (* s2i s1i)))
            (setf s2i (+ (* s2r s1i) (* s2i s1r)))
            (setf s2r str)
            (if (/= iflag 1) (go label230))
            (multiple-value-bind (var-0 var-1 var-2 var-3 var-4)
                (zuchk s2r s2i nw (f2cl-lib:fref bry (1) ((1 3))) tol)
              (declare (ignore var-0 var-1 var-3 var-4))
              (setf nw var-2))
            (if (= nw 0) (go label230))
            (setf s2r zeror)
            (setf s2i zeroi)
           label230
            (setf (f2cl-lib:fref cyr (kdflg) ((1 2))) s2r)
            (setf (f2cl-lib:fref cyi (kdflg) ((1 2))) s2i)
            (setf c2r s2r)
            (setf c2i s2i)
            (setf s2r (* s2r (f2cl-lib:fref csrr (iflag) ((1 3)))))
            (setf s2i (* s2i (f2cl-lib:fref csrr (iflag) ((1 3)))))
            (setf s1r (f2cl-lib:fref yr-%data% (kk) ((1 n)) yr-%offset%))
            (setf s1i (f2cl-lib:fref yi-%data% (kk) ((1 n)) yi-%offset%))
            (if (= kode 1) (go label250))
            (multiple-value-bind
                  (var-0 var-1 var-2 var-3 var-4 var-5 var-6 var-7 var-8 var-9)
                (zs1s2 zrr zri s1r s1i s2r s2i nw asc alim iuf)
              (declare (ignore var-0 var-1 var-7 var-8))
              (setf s1r var-2)
              (setf s1i var-3)
              (setf s2r var-4)
              (setf s2i var-5)
              (setf nw var-6)
              (setf iuf var-9))
            (setf nz (f2cl-lib:int-add nz nw))
           label250
            (setf (f2cl-lib:fref yr-%data% (kk) ((1 n)) yr-%offset%)
                    (+ (- (* s1r cspnr) (* s1i cspni)) s2r))
            (setf (f2cl-lib:fref yi-%data% (kk) ((1 n)) yi-%offset%)
                    (+ (* cspnr s1i) (* cspni s1r) s2i))
            (setf kk (f2cl-lib:int-sub kk 1))
            (setf cspnr (- cspnr))
            (setf cspni (- cspni))
            (if (or (/= c2r 0.0) (/= c2i 0.0)) (go label255))
            (setf kdflg 1)
            (go label270)
           label255
            (if (= kdflg 2) (go label275))
            (setf kdflg 2)
            (go label270)
           label260
            (if (> rs1 0.0) (go label300))
            (setf s2r zeror)
            (setf s2i zeroi)
            (go label230)
           label270))
        (setf k n)
       label275
        (setf il (f2cl-lib:int-sub n k))
        (if (= il 0) (go end_label))
        (setf s1r (f2cl-lib:fref cyr (1) ((1 2))))
        (setf s1i (f2cl-lib:fref cyi (1) ((1 2))))
        (setf s2r (f2cl-lib:fref cyr (2) ((1 2))))
        (setf s2i (f2cl-lib:fref cyi (2) ((1 2))))
        (setf csr (f2cl-lib:fref csrr (iflag) ((1 3))))
        (setf ascle (f2cl-lib:fref bry (iflag) ((1 3))))
        (setf fn
                (coerce (the f2cl-lib:integer4 (f2cl-lib:int-add inu il))
                        'double-float))
        (f2cl-lib:fdo (i 1 (f2cl-lib:int-add i 1))
                      ((> i il) nil)
          (tagbody
            (setf c2r s2r)
            (setf c2i s2i)
            (setf s2r (+ s1r (* (+ fn fnf) (- (* rzr c2r) (* rzi c2i)))))
            (setf s2i (+ s1i (* (+ fn fnf) (+ (* rzr c2i) (* rzi c2r)))))
            (setf s1r c2r)
            (setf s1i c2i)
            (setf fn (- fn 1.0))
            (setf c2r (* s2r csr))
            (setf c2i (* s2i csr))
            (setf ckr c2r)
            (setf cki c2i)
            (setf c1r (f2cl-lib:fref yr-%data% (kk) ((1 n)) yr-%offset%))
            (setf c1i (f2cl-lib:fref yi-%data% (kk) ((1 n)) yi-%offset%))
            (if (= kode 1) (go label280))
            (multiple-value-bind
                  (var-0 var-1 var-2 var-3 var-4 var-5 var-6 var-7 var-8 var-9)
                (zs1s2 zrr zri c1r c1i c2r c2i nw asc alim iuf)
              (declare (ignore var-0 var-1 var-7 var-8))
              (setf c1r var-2)
              (setf c1i var-3)
              (setf c2r var-4)
              (setf c2i var-5)
              (setf nw var-6)
              (setf iuf var-9))
            (setf nz (f2cl-lib:int-add nz nw))
           label280
            (setf (f2cl-lib:fref yr-%data% (kk) ((1 n)) yr-%offset%)
                    (+ (- (* c1r cspnr) (* c1i cspni)) c2r))
            (setf (f2cl-lib:fref yi-%data% (kk) ((1 n)) yi-%offset%)
                    (+ (* c1r cspni) (* c1i cspnr) c2i))
            (setf kk (f2cl-lib:int-sub kk 1))
            (setf cspnr (- cspnr))
            (setf cspni (- cspni))
            (if (>= iflag 3) (go label290))
            (setf c2r (abs ckr))
            (setf c2i (abs cki))
            (setf c2m (max c2r c2i))
            (if (<= c2m ascle) (go label290))
            (setf iflag (f2cl-lib:int-add iflag 1))
            (setf ascle (f2cl-lib:fref bry (iflag) ((1 3))))
            (setf s1r (* s1r csr))
            (setf s1i (* s1i csr))
            (setf s2r ckr)
            (setf s2i cki)
            (setf s1r (* s1r (f2cl-lib:fref cssr (iflag) ((1 3)))))
            (setf s1i (* s1i (f2cl-lib:fref cssr (iflag) ((1 3)))))
            (setf s2r (* s2r (f2cl-lib:fref cssr (iflag) ((1 3)))))
            (setf s2i (* s2i (f2cl-lib:fref cssr (iflag) ((1 3)))))
            (setf csr (f2cl-lib:fref csrr (iflag) ((1 3))))
           label290))
        (go end_label)
       label300
        (setf nz -1)
        (go end_label)
       end_label
        (return (values nil nil nil nil nil nil nil nil nz nil nil nil))))))

(in-package #:cl-user)
#+#.(cl:if (cl:find-package '#:f2cl) '(:and) '(:or))
(eval-when (:load-toplevel :compile-toplevel :execute)
  (setf (gethash 'fortran-to-lisp::zunk1 fortran-to-lisp::*f2cl-function-info*)
          (fortran-to-lisp::make-f2cl-finfo
           :arg-types '((double-float) (double-float) (double-float)
                        (fortran-to-lisp::integer4) (fortran-to-lisp::integer4)
                        (fortran-to-lisp::integer4) (array double-float (*))
                        (array double-float (*)) (fortran-to-lisp::integer4)
                        (double-float) (double-float) (double-float))
           :return-values '(nil nil nil nil nil nil nil nil fortran-to-lisp::nz
                            nil nil nil)
           :calls '(fortran-to-lisp::zs1s2 fortran-to-lisp::zuchk
                    fortran-to-lisp::zabs fortran-to-lisp::zunik
                    fortran-to-lisp::d1mach))))

