;;; -*-  Mode: Lisp; Package: Maxima; Syntax: Common-Lisp; Base: 10 -*- ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     The data in this file contains enhancments.                    ;;;;;
;;;                                                                    ;;;;;
;;;  Copyright (c) 1984,1987 by William Schelter,University of Texas   ;;;;;
;;;     All rights reserved                                            ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     (c) Copyright 1982 Massachusetts Institute of Technology         ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "MAXIMA")
(macsyma-module combin)


(declare-top (special *mfactl *factlist donel nn* dn* splist *ans* *var*
		      dict ans var
		      a* $zerobern *a *n $cflength *a* $prevfib hi lo
		      *infsumsimp *times *plus sum usum makef
		      varlist genvar $sumsplitfact gensim $ratfac $simpsum
		      $prederror $listarith $sumhack $prodhack
		      $ratprint $zeta%pi $bftorat)
	     ;;	 (*lexpr $ratcoef $divide)
	     ;;	 (fixnum %n %a* %i %m)
	     ;;	 (genprefix comb)
	     )

(load-macsyma-macros mhayat rzmac ratmac)

;;(declare-top (splitfile minfct))

;;(comment minfactorial and factcomb stuff)

(defmfun $makefact (e)
  (let ((makef t)) (if (atom e) e (simplify (makefact1 e)))))

(defun makefact1 (e)
  (cond ((atom e) e)
	((eq (caar e) '%binomial)
	 (subst (makefact1 (cadr e)) 'x
		(subst (makefact1 (caddr e)) 'y
		       '((mtimes) ((mfactorial) x)
			 ((mexpt) ((mfactorial) y) -1)
			 ((mexpt) ((mfactorial) ((mplus) x ((mtimes) -1 y)))
			  -1)))))
	((eq (caar e) '%gamma)
	 (list '(mfactorial) (list '(mplus) -1 (makefact1 (cadr e)))))
	((eq (caar e) '$beta)
	 (makefact1 (subst (cadr e) 'x
			   (subst (caddr e) 'y
				  '((mtimes) ((%gamma) x)
				    ((%gamma) y)
				    ((mexpt) ((%gamma) ((mplus) x y)) -1))))))
	(t (recur-apply #'makefact1 e))))

(defmfun $makegamma (e)
  (if (atom e) e (simplify (makegamma1 ($makefact e)))))

(defmfun $minfactorial (e)
  (let (*mfactl *factlist)
    (if (specrepp e) (setq e (specdisrep e)))
    (getfact e)
					;(maplist #'evfac1 *factlist)		;this is to save consing
					;If it was to save consing, why was MAPLIST used?
    (mapl #'evfac1 *factlist)
    (setq e (evfact e))))

(defun evfact (e)
  (cond ((atom e) e)
	((eq (caar e) 'mfactorial)
	 (cdr (zl-assoc (cadr e) *factlist)))
	((memq  (caar e) '(%sum %derivative %integrate %product))
	 (cons (list (caar e)) (cons (evfact (cadr e)) (cddr e))))
	(t (recur-apply #'evfact e))))

(defun adfactl (e l)
  (let (n)
    (cond ((null l) (setq *mfactl (cons (list e) *mfactl)))
	  ((numberp (setq n ($ratsimp `((mplus) ,e ((mtimes) -1 ,(caar l))))))
	   (cond ((plusp n)
					;(signp g n)
		  (rplacd (car l) (cons e (cdar l))))
		 ((rplaca l (cons e (car l))))))
	  ((adfactl e (cdr l))))))

(defun getfact (e)
  (cond ((atom e) nil)
	((eq (caar e) 'mfactorial)
	 (and (null (zl-member (cadr e) *factlist))
	      (prog2 (setq *factlist (cons (cadr e) *factlist))
		  (adfactl (cadr e) *mfactl))))
	((memq (caar e) '(%sum %derivative %integrate %product))
	 (getfact (cadr e)))
	((mapc #'getfact (cdr e)))))

(defun evfac1 (e)
  (do ((al *mfactl (cdr al)))
      ((zl-member (car e) (car al))
       (rplaca e
	       (cons (car e)
		     (list '(mtimes)
			   (gfact (car e)
				  ($ratsimp (list '(mplus) (car e)
						  (list '(mtimes) -1 (caar al)))) 1)
			   (list '(mfactorial) (caar al))))))))
(defmfun $factcomb (e)
  (let ((varlist varlist ) genvar $ratfac (ratrep (and (not (atom e)) (eq (caar e) 'mrat))))
    (and ratrep (setq e (ratdisrep e)))
    (setq e (factcomb e)
	  e (cond ((atom e) e)
		  (t (simplify (cons (list (caar e))
				     (mapcar #'factcomb1 (cdr e)))))))
    (or $sumsplitfact (setq e ($minfactorial e)))
    (cond (ratrep (ratf e))
	  (t e))))

(defun factcomb1 (e)
  (cond ((free e 'mfactorial) e)
	((memq (caar e) '(mplus mtimes mexpt))
	 (cons (list (caar e)) (mapcar #'factcomb1 (cdr e))))
	(t (setq e (factcomb e))
	   (cond ((atom e) e)
		 (t (cons (list (caar e))
			  (mapcar #'factcomb1 (cdr e))))))))

(defun factcomb (e)
  (cond ((atom e) e)
	((free e 'mfactorial) e)
	((memq (caar e) '(mplus mtimes))
	 (factpluscomb (factcombplus e)))
	((eq (caar e) 'mexpt)
	 (simpexpt (list '(mexpt) (factcomb (cadr e))
			 (factcomb (caddr e)))
		   1 nil))
	((eq (caar e) 'mrat)
	 (factrat e))
	(t (cons (car e) (mapcar #'factcomb (cdr e))))))

(defun factrat (e)
  (let (nn* dn*)
    (setq e (factqsnt ($ratdisrep (cons (car e) (cons (cadr e) 1)))
		      ($ratdisrep (cons (car e) (cons (cddr e) 1)))))
    (numden e)
    (div* (factpluscomb nn*) (factpluscomb dn*))))

(defun factqsnt (num den)
  (if (equal num 0) 0
      (let (nn* dn* (e (factpluscomb (div* den num))))
	(numden e)
	(factpluscomb (div* dn* nn*)))))

(defun factcombplus (e)
  (let (nn* dn*)
    (do ((l1 (nplus e) (cdr l1))
	 (l2))
	((null l1)
	 (simplus (cons '(mplus)
			(mapcar #'(lambda (q) (factqsnt (car q) (cdr q))) l2))
		  1 nil))
      (numden (car l1))
      (do ((l3 l2 (cdr l3))
	   (l4))
	  ((null l3) (setq l2 (nconc l2 (list (cons nn* dn*)))))
	(setq l4 (car l3))
	(cond ((not (free ($gcd dn* (cdr l4)) 'mfactorial))
	       (numden (list '(mplus) (div* nn* dn*)
			     (div* (car l4) (cdr l4))))
	       (setq l2 (delq l4 l2 1))))))))

(defun factpluscomb (e)
  (prog (donel fact indl tt)
   tag (setq e (factexpand e)
	     fact (getfactorial e))
   (or fact (return e))
   (setq indl (mapcar #'(lambda (q) (factplusdep q fact))
		      (nplus e))
	 tt (factpowerselect indl (nplus e) fact)
	 e (cond ((cdr tt)
		  (cons '(mplus) (mapcar #'(lambda (q) (factplus2 q fact))
					 tt)))
		 (t (factplus2 (car tt) fact))))
   (go tag)))

(defun nplus (e)
  (cond ((eq (caar e) 'mplus) (cdr e))
	(t (list e))))

(defun factexpand (e)
  (cond ((atom e) e)
	((eq (caar e) 'mplus)
	 (simplus (cons '(mplus) (mapcar #'factexpand (cdr e)))
		  1 nil))
	((free e 'mfactorial) e)
	(t ($expand e))))

(defun getfactorial (e)
  (cond ((atom e) nil)
	((memq (caar e) '(mplus mtimes))
	 (do ((e (cdr e) (cdr e))
	      (a))
	     ((null e) nil)
	   (setq a (getfactorial (car e)))
	   (and a (return a))))
	((eq (caar e) 'mexpt)
	 (getfactorial (cadr e)))
	((eq (caar e) 'mfactorial)
	 (and (null (memalike (cadr e) donel))
	      (list '(mfactorial)
		    (car (setq donel (cons (cadr e) donel))))))))

(defun factplusdep (e fact)
  (cond ((alike1 e fact) 1)
	((atom e) nil)
	((eq (caar e) 'mtimes)
	 (do ((l (cdr e) (cdr l))
	      (e) (out))
	     ((null l) nil)
	   (setq e (car l))
	   (and (setq out (factplusdep e fact))
		(return out))))
	((eq (caar e) 'mexpt)
	 (let ((fto (factplusdep (cadr e) fact)))
	   (and fto (simptimes (list '(mtimes) fto
				     (caddr e)) 1 t))))
	((eq (caar e) 'mplus)
	 (same (mapcar #'(lambda (q) (factplusdep q fact))
		       (cdr e))))))

(defun same (l)
  (do ((ca (car l))
       (cd (cdr l) (cdr cd))
       (cad))
      ((null cd) ca)
    (setq cad (car cd))
    (or (alike1 ca cad)
	(return nil))))

(defun factpowerselect (indl e fact)
  (let (l fl)
    (do ((i indl (cdr i))
	 (j e (cdr j))
	 (expt) (exp))
	((null i) l)
      (setq expt (car i)
	    exp (cond (expt
		       (setq exp ($divide (car j) `((mexpt) ,fact ,expt)))
		       ;; (car j) need not involve fact^expt since
		       ;; fact^expt may be the gcd of the num and denom
		       ;; of (car j) and $divide will cancel this out.
		       (if (not (equal (cadr exp) 0))
			   (cadr exp)
			   (progn
			     (setq expt '())
			     (caddr exp))))
		      (t (car j))))
      (cond ((null l) (setq l (list (list expt exp))))
	    ((setq fl (assolike expt l))
	     (nconc fl (list exp)))
	    (t (nconc l (list (list expt exp))))))))

(defun factplus2 (l fact)
  (let ((expt (car l)))
    (cond (expt (factplus0 (cond ((cddr l) (rplaca l '(mplus)))
				 (t (cadr l)))
			   expt (cadr fact)))
	  (t (rplaca l '(mplus))))))

(defun factplus0 (r e fact)
  (do ((i -1 (f1- i))
       (fpn fact (list '(mplus) fact i))
       (j -1) (exp) (rfpn) (div))
      (nil)
    (setq rfpn (simpexpt (list '(mexpt) fpn -1) 1 nil))
    (setq div (dypheyed r (simpexpt (list '(mexpt) rfpn e) 1 nil)))
    (cond ((or (null (or $sumsplitfact (equal (cadr div) 0)))
	       (equal (car div) 0))
	   (return (simplus (cons '(mplus) (mapcar
					    #'(lambda (q)
						(setq j (f1+ j))
						(list '(mtimes) q (list '(mexpt)
									(list '(mfactorial) (list '(mplus) fpn j)) e)))
					    (factplus1 (cons r exp) e fpn)))
			    1 nil)))
	  (t (setq r (car div))
	     (setq exp (cons (cadr div) exp))))))

(defun factplus1 (exp e fact)
  (do ((l exp (cdr l))
       (i 2 (f1+ i))
       (fpn (list '(mplus) fact 1) (list '(mplus) fact i))
       (div))
      ((null l) exp)
    (setq div (dypheyed (car l) (list '(mexpt) fpn e)))
    (and (or $sumsplitfact (equal (cadr div) 0))
	 (null (equal (car div) 0))
	 (rplaca l (cadr div))
	 (rplacd l (cons (cond ((cadr l)
				(simplus (list '(mplus) (car div) (cadr l))
					 1 nil))
			       (t
				(setq donel
				      (cons (simplus fpn 1 nil) donel))
				(car div)))
			 (cddr l))))))

(defun dypheyed (r f)
  (let (r1 p1 p2)
    (newvar r)
    (setq r1 (ratf f)
	  p1 (pdegreevector (cadr r1))
	  p2 (pdegreevector (cddr r1)))
    (do ((i p1 (cdr i))
	 (j p2 (cdr j))
	 (k (caddar r1) (cdr k)))
	((null k) (kansel r (cadr r1) (cddr r1)))
      (cond ((> (car i) (car j))
	     (return (cdr ($divide r f (car k)))))))))

(defun kansel (r n d)
  (let (r1 p1 p2)
    (setq r1 (ratf r)
	  p1 (testdivide (cadr r1) n)
	  p2 (testdivide (cddr r1) d))
    (cond ((and p1 p2) (cons (rdis (cons p1 p2)) '(0)))
	  (t (cons '0 (list r))))))

;;(declare-top (splitfile eulbrn)
;;	 (array* (notype *eu* 1 *bn* 1 *bd* 1)
;;		 )

;;(comment euler and bernoulli stuff)

(eval-when (compile eval load)

  (defvar *bn*
    (vector nil -1. 1. -1. 5. -691. 7. -3617. 43867. -174611. 854513.
	    -236364091. 8553103. -23749461029. 8615841276005.
	    -7709321041217. 2577687858367.))

  (defvar *bd*
    (vector nil 30. 42. 30. 66. 2730. 6. 510. 798. 330. 138. 2730. 6. 870.
	    14322.  510. 6.))

  (defvar *eu*
    (vector -1. 5. -61. 1385. -50521. 2702765. -199360981. 19391512145.
	    -2404879675441. 370371188237525. -69348874393137901.)))

;;#-cl
;;(progn 'compile
;;(defvar *bn* (*array nil t 20.))
;;(defvar *bd* (*array nil t 20.))
;;(defvar *eu* (*array nil t 20.))

;;(setq i 0)
;;(mapc #'(lambda (q)
;;	  (store (aref *bn* (setq i (f1+ i))) q))
;;	  '(-1. 1. -1. 5. -691. 7. -3617. 43867. -174611. 854513. -236364091.
;;		8553103. -23749461029. 8615841276005. -7709321041217. 2577687858367.))


;;(setq i 0)
;;(mapc #'(lambda (a)
;;	   (store (aref *bd* (setq i (f1+ i))) a))
;;      '(30. 42. 30. 66. 2730. 6. 510. 798. 330. 138. 2730. 6. 870. 14322.
;;        510. 6.))

;;(setq i -1)
;;(mapc #'(lambda (a)
;;	  (store (aref *eu* (setq i (f1+ i))) a))
;;      '(-1. 5. -61. 1385. -50521. 2702765. -199360981. 19391512145.
;;	    -2404879675441. 370371188237525. -69348874393137901.))
;;)


(putprop '*eu* 11 'lim)
(putprop 'bern 16 'lim)

(defmfun $euler (s)
  (setq s
	(let ((%n 0) $float)
	  (cond ((or (not (fixnump s)) (< s 0)) (list '($euler) s))
		((= (setq %n s) 0) 1)
		($zerobern
		 (cond ((oddp %n) 0)
		       ((null (> (// %n 2) (get '*eu* 'lim)))
			(aref *eu* (f1- (// %n 2))))
		       ((eq $zerobern '%$/#&)
			(euler %n))
		       ((*rearray '*eu* t (f1+ (// %n 2))) 
			(euler %n))))
		((null (> %n (get '*eu* 'lim)))
		 (aref *eu* (f1- %n)))
		((*rearray '*eu* t (f1+ %n))
		 (euler (f* 2 %n))))))
  (simplify s))

(defun euler (%a*)
  (prog (nom %k e fl $zerobern *a*)
     (setq nom 1 %k %a* fl nil e 0 $zerobern '%$/#& *a* (f1+ %a*))
     a	(cond ((= %k 0)
	       (setq e (minus e))
					;(eval (list 'store (list '*eu* (f1- (// %a* 2))) e))
	       (store (aref *eu* (f1- (// %a* 2))) e)
	       (putprop '*eu* (// %a* 2) 'lim)
	       (return e)))
     (setq nom (nxtbincoef (f1+ (- %a* %k)) nom) %k (f1- %k))
     (cond ((setq fl (null fl))
	    (go a)))
     (setq e (plus e (times nom ($euler %k))))
     (go a)))

(defmfun simpeuler (x vestigial z) 
  vestigial				;ignored.
  (oneargcheck x)
  (let ((u (simpcheck (cadr x) z)))
    (if (and (fixnump u) (not (< u 0)))
	($euler u)
	(eqtest (list '($euler) u) x))))

(defmfun $bern (s)
  (setq s 
	(let ((%n 0) $float)
	  (cond ((or (not (fixnump s)) (< s 0)) (list '($bern) s))
		((= (setq %n s) 0) 1)
		((= %n 1) '((rat) -1 2))
		((= %n 2) '((rat) 1 6))
		($zerobern
		 (cond ((oddp %n) 0)
		       ((null (> (setq %n (f1- (// %n 2))) (get 'bern 'lim)))
			(list '(rat) (aref *bn* %n) (aref *bd* %n)))
		       ((eq $zerobern '$/#&) (bern  (f* 2 (f1+ %n))))
		       (t (*rearray '*bn* t (setq %n (f1+ %n)))
			  (*rearray '*bd* t %n) (bern  (f* 2 %n)))))
		((null (> %n (get 'bern 'lim)))
		 (list '(rat) (aref *bn* %n) (aref *bd* %n)))
		(t (*rearray '*bn* t (f1+ %n)) (*rearray '*bd* t (f1+ %n))
		   (bern %n)))))
  (simplify s))

(defun bern (%a*)
  (prog (nom %k bb a b $zerobern l *a*)
     (setq %k 0
	   l (f1- %a*)
	   %a* (f1+ %a*)
	   nom 1
	   $zerobern '$/#&
	   a 1
	   b 1
	   *a* (f1+ %a*))
     a	(cond ((= %k l)
	       (setq bb (*red a (times -1 b %a*)))
	       (putprop 'bern (setq %a* (f1- (// %a* 2))) 'lim)
					;if bb is a list, then it will always be
					;((RAT SIMP) number number).  ergo, evaluation
					; by store is no-op.
					;(eval (list 'store (list '*bn* %a*) (cadr bb)))
					;(eval (list 'store (list '*bd* %a*) (caddr bb)))
	       (store (aref *bn* %a*) (cadr bb))
	       (store (aref *bd* %a*) (caddr bb))
	       (return bb)))
     (setq %k (f1+ %k))
     (setq a (plus (times b (setq nom (nxtbincoef %k nom))
			  (num1 (setq bb ($bern %k))))
		   (times a (denom1 bb))))
     (setq b (times b (denom1 bb)))
     (setq a (*red a b) b (denom1 a) a (num1 a))
     (go a)))

(defmfun simpbern (x vestigial z) 
  vestigial				;ignored.
  (oneargcheck x)
  (let ((u (simpcheck (cadr x) z)))
    (if (and (fixnump u) (not (< u 0)))
	($bern u)
	(eqtest (list '($bern) u) x))))

(defmfun $bernpoly (x s)
  (let ((%n 0))
    (cond ((not (fixnump s)) (list '($bernpoly) x s))
	  ((> (setq %n s) -1)
	   (do ((sum (cons (if (and (= %n 0) (zerop1 x))
			       (addk 1 x)
			       (power x %n)) nil)
		     (cons (m* (timesk (binocomp %n %k) ($bern %k))
			       (if (and (= %n %k) (zerop1 x))
				   (addk 1 x)
				   (m^ x (f- %n %k))))
			   sum))
		(%k 1 (f1+ %k)))
	       ((> %k %n) (addn sum t))))
	  (t (list '($bernpoly) x %n)))))

;;(declare-top (splitfile zeta))

;;(comment zeta and fibonacci stuff)

(defmfun $zeta (s)
  (cond ((null (fixnump s)) (list '($zeta) s))
	((oddp s)
	 (cond ((greaterp s 0)
		(list '($zeta) s))
	       ((setq s (*dif 1 s))
		(timesk -1
			(timesk ($bern s) (list '(rat)
						(expt -1 (*quo s 2)) s))))))
	((equal s 0) '((rat simp) -1 2))
	((minusp s) 0)
	((not $zeta%pi) (list '($zeta) s))
	(t (let ($numer $float)
	     (setq s (mul2 (power '$%pi s)
			   (timesk (*red (expt 2 (sub1 s)) (factorial s))
				   (simpabs (list 'mabs ($bern s)) 1 nil)))))
	   (resimplify s))))

(defmfun $fib (n) 
  (cond ((fixnump n) (ffib n))
	(t (setq $prevfib (list '($fib) (add2* n -1)))
	   (list '($fib) n))))

(defun ffib (%n) 
  (cond ((or (equal %n -1.) (zerop %n))
	 (setq $prevfib (boole boole-ior %n 1.) *a (f- %n)))
	(t
	 (let ((x (plus (ffib (// (boole  boole-andc2 %n 1.) 2.)) $prevfib))
	       (y (times $prevfib $prevfib))
	       (z (times *a *a)))
	   (setq *a (*dif (times x x) y)
		 $prevfib (plus y z)))
	 (cond ((oddp %n)
		(setq *a (prog2
			     nil
			     (plus *a $prevfib)
			   (setq $prevfib *a))))
	       (*a)))))

;;(declare-top (splitfile cffun))

;;(comment continued fraction stuff)

(defmfun $cfdisrep (a)
  (cond ((not ($listp a))
	 (merror "Arg to `cfdisrep' not a list: ~M" a))
	((null (cddr a)) (cadr a))
	((zerop (cadr a))
	 (list '(mexpt) (cfdisrep1 (cddr a)) -1))
	((cfdisrep1 (cdr a)))))

(defun cfdisrep1 (a)
  (cond ((cdr a)
	 (list '(mplus simp cf) (car a)
	       (prog2 (setq a (cfdisrep1 (cdr a)))
		   (cond ((integerp a) (list '(rat simp) 1 a))
			 (t (list '(mexpt simp) a -1))))))
	((car a))))

(defun cfmak (a)
  (setq a (meval a))
  (cond ((integerp a) (list a))
	((eq (caar a) 'mlist) (cdr a))
	((eq (caar a) 'rat) (ratcf (cadr a) (caddr a)))
	((merror "Continued fractions must be lists or integers"))))

(defun makcf (a)
  (cond ((null (cdr a)) (car a))
	((cons '(mlist simp cf) a))))

;;; Translation properties for $CF defined in MAXSRC;TRANS5 >

(defmacro bind-status-divov-t (&rest forms)
  (cond
    ;;	    #-cl
    ;;	    ((status feature maclisp)
    ;;		 `(let ((divov (status divov)))
    ;;		       (unwind-protect
    ;;			(progn (sstatus divov t)
    ;;			       ,@forms)
    ;;			(sstatus divov divov))))
    (t
     `(progn ,@forms))))

(defmspec $cf (a)
  (cfratsimp  (let ($listarith)
		(bind-status-divov-t (cfeval (meval (fexprcheck a)))))))

(defun cfratsimp (a)
  (cond ((memq (car a) '(cf)) a)
	(t
	 (cons '(mlist cf simp)(apply 'find-cf (cf-back-recurrence (cdr a)))))))

(defun cfeval (a)
  (let (temp $ratprint)
    (cond ((integerp a) (list '(mlist cf) a))
	  ((floatp a)
	   (let ((a (maxima-rationalize a)))
	     (cons '(mlist cf) (ratcf (car a) (cdr a)))))
	  (($bfloatp a)
	   (let (($bftorat t))
	     (setq a (bigfloat2rat a))
	     (cons '(mlist cf) (ratcf (car a) (cdr a)))))
	  ((atom a)
	   (merror "~:M - not a continued fraction" a))
	  ((eq (caar a) 'rat)
	   (cons '(mlist cf) (ratcf (cadr a) (caddr a))))
	  ((eq (caar a) 'mlist)
	   (cfratsimp a))
	  ;;the following doesn't work for non standard form
	  ;;		(cfplus a '((mlist) 0)))
	  ((and (mtimesp a) (cddr a) (null (cdddr a))
		(fixnump (cadr a))
		(mexptp (caddr a))
		(fixnump (cadr (caddr a)))
		(alike1 (caddr (caddr a)) '((rat) 1 2)))
	   (cfsqrt (cfeval (times (expt (cadr a) 2) (cadr (caddr a))))))
	  ((eq (caar a) 'mexpt)
	   (cond ((alike1 (caddr a) '((rat) 1 2))
		  (cfsqrt (cfeval (cadr a))))
		 ((integerp (m- (caddr a) '((rat) 1 2)))
		  (cftimes (cfsqrt (cfeval (cadr a)))
			   (cfexpt (cfeval (cadr a))
				   (m- (caddr a) '((rat) 1 2)))))
		 ((cfexpt (cfeval (cadr a)) (caddr a)))))
	  ((setq temp (assq (caar a) '((mplus . cfplus) (mtimes . cftimes) (mquotient . cfquot)
				       (mdifference . cfdiff) (mminus . cfminus))))
	   (cf (cfeval (cadr a)) (cddr a) (cdr temp)))
	  ((eq (caar a) 'mrat)
	   (cfeval ($ratdisrep a)))
	  (t (merror "Not a continued fraction:~%~M" a)))))

(defun cf (a l fun)
  (cond ((null l) a)
	((cf (funcall fun a (meval (list '($cf) (car l)))) (cdr l) fun))))

(defun cfplus (a b)
  (setq a (cfmak a) b (cfmak b))
  (makcf (cffun '(0 1 1 0) '(0 0 0 1) a b)))

(defun cftimes (a b)
  (setq a (cfmak a) b (cfmak b))
  (makcf (cffun '(1 0 0 0) '(0 0 0 1) a b)))

(defun cfdiff (a b)
  (setq a (cfmak a) b (cfmak b))
  (makcf (cffun '(0 1 -1 0) '(0 0 0 1) a b)))

(defun cfmin (a)
  (setq a (cfmak a))
  (makcf (cffun '(0 0 -1 0) '(0 0 0 1) a '(0))))

(defun cfquot (a b)
  (setq a (cfmak a) b (cfmak b))
  (makcf (cffun '(0 1 0 0) '(0 0 1 0) a b)))

(defun cfexpt (b e)
  (setq b (cfmak b))
  (cond ((null (integerp e))
	 (merror "Can't raise continued fraction to non-integral powers"))
	((let ((n (abs e)))
	   (do ((n (// n 2) (// n 2))
		(s (cond ((oddp n) b)
			 (t '(1)))))
	       ((zerop n)
		(makcf
		 (cond ((signp g e)
			s)
		       ((cffun '(0 0 0 1) '(0 1 0 0) b '(1))))))
	     (setq b (cffun '(1 0 0 0) '(0 0 0 1) b b))
	     (and (oddp n)
		  (setq s (cffun '(1 0 0 0) '(0 0 0 1) s b))))))))


;;(defun conf1 (f g a b)
;;  (*quo (conf2 f a b ) (conf2 g a b)))

(defun conf1 (f g a b &aux (den (conf2 g a b)))
  (cond ((zerop den)
	 (* (signum (conf2 f a b )) ;#+cl (/ most-positive-fixnum (^ 2 4))
	    #.(expt 2 31)))
	(t (*quo (conf2 f a b) den))))

(defun conf2 (n a b)			;2*(abn_0+an_1+bn_2+n_3)
  (times 2 (plus (times (car n) a b)
		 (times (cadr n) a)
		 (times (caddr n) b)
		 (cadddr n))))

;;(cffun '(0 1 1 0) '(0 0 0 1) '(1 2) '(1 1 1 2)) gets error
;;should give (3 10)

(defun cf-convergents-p-q (cf &optional (n (length cf)) &aux pp qq)
  "returns two lists such that pp_i/qq_i is the quotient of the first i terms
   of cf"
  (case (length cf)
    (0 1)
    (1  cf(list 1))
    (t
     (setq pp (list (add1
		     (* (first cf) (second cf)))
		    (car cf)))
     (setq qq (list (second cf) 1))
     (show pp qq)
     (setq cf (cddr cf))
     (loop for i from 2 to n
	    while cf
	    do 
	    (push (+  (* (car cf) (car pp))
		      (second pp)) pp)
	    (push (+  (* (car cf) (car qq))
		      (second qq)) qq)
	    (setq cf (cdr cf))
	    finally (return (list (reverse pp) (reverse qq)))))))


(defun find-cf1 (p q &optional so-far quot zl-rem )
  (setq quot (quotient p q))
  (setq zl-rem (- p (* quot q) ))
  (prog ()
     (cond ((< zl-rem 0) (incf zl-rem q) (incf quot -1))
	   ((zerop zl-rem) (return (cons quot so-far))))
     (setq so-far (cons quot so-far))
     (return (find-cf1 q zl-rem so-far))))
 
;;(compare-functions 
;;the following are equivalent but find-cf faster.

(defun find-cf (p q)
  "returns the continued fraction for p and q integers, q not zero"
  (cond  ((zerop q)(error "quotient by zero"))
	 ((< q 0) (setq p (f- p)) (setq q (f- q))))
  (nreverse (find-cf1 p q))) 

;;this works but since it is slower than find-cf
;;(defun standard-cf (p q &aux start  tem new-q)
;; "returns the continued fraction for p and q integers, q not zero"
;;  (setq start (floor p q))
;;  (setq p (f- p (f* start q)))
;;  (loop until (zerop q)
;;	when start
;;	  collecting start
;;	and
;;	do(setq tem (floor p q))(setq start nil)
;;	else
;;	  collecting (setq tem (floor p q))
;;	do
;;	       (setq new-q (f- p (f* tem q)))
;;	       (setq p q)
;;	       (setq q new-q)))
;;)


(defun cf-back-recurrence (cf &aux tem (num-gg 0)(den-gg 1))
  "converts CF (a continued fraction list) to a list of numerator
  denominator using  recurrence from end
  and not calculating intermediate quotients.
  The numerator and denom are relatively
   prime"
  (loop for v in (reverse cf)
	 do (setq tem (* den-gg v))
	 (setq tem (+ tem num-gg))
	 (setq num-gg den-gg)
	 (setq den-gg tem)
	 finally
	 (return
	   (cond ((and (<= den-gg 0) (< num-gg 0))
		  (list  (- den-gg) (- num-gg)))
		 (t(list den-gg num-gg))))))

(declare-top (unspecial w))

;;(cffun '(0 1 1 0) '(0 0 0 1) '(1 2) '(1 1 1 2)) gets error
;;should give (3 10)

(defun cffun (f g a b)
  (prog (c v w)
     (declare (special v))
     a   (and (zerop (cadddr g))
	      (zerop (caddr g))
	      (zerop (cadr g))
	      (zerop (car g))
	      (return (reverse c)))
     (and (equal (setq w (conf1 f g (car a) (add1 (car b))))
		 (setq v (conf1 f g (car a) (car b))))
	  (equal (conf1 f g (add1 (car a)) (car b)) v)
	  (equal (conf1 f g (add1 (car a)) (add1 (car b))) v)
	  (setq g (mapcar #'(lambda (a b)
			      (declare (special v))
			      (*dif a (times v b)))
			  f (setq f g)))
	  (setq c (cons v c))
	  ;;	     (progn (show v w) t)
	  (go a))
     ;;	(show v w)
     (cond ((lessp (abs (*dif (conf1 f g (add1 (car a)) (car b)) v))
		   (abs (*dif w v)))
	    (cond ((setq v (cdr b))
		   (setq f (conf6 f b))
		   (setq g (conf6 g b))
		   (setq b v))
		  (t (setq f (conf7 f b)) (setq g  (conf7 g b)))))
	   (t
	    (cond ((setq v (cdr a))
		   (setq f (conf4 f a))
		   (setq g (conf4 g a))
		   (setq a v))
		  (t (setq f (conf5 f a)) (setq g  (conf5 g a))))))
     (go a)))

(defun conf4 (n a)		      ;n_0*a_0+n_2,n_1*a_0+n_3,n_0,n_1
  (list (plus (times (car n) (car a)) (caddr n))
	(plus (times (cadr n) (car a)) (cadddr n))
	(car n)
	(cadr n)))

(defun conf5 (n a)			;0,0, n_0*a_0,n_2
  (list 0 0
	(plus (times (car n) (car a)) (caddr n))
	(plus (times (cadr n) (car a)) (cadddr n))))

(defun conf6 (n b)
  (list (plus (times (car n) (car b)) (cadr n))
	(car n)
	(plus (times (caddr n) (car b)) (cadddr n))
	(caddr n)))

(defun conf7 (n b)
  (list 0 (plus (times (car n) (car b)) (cadr n))
	0 (plus (times (caddr n) (car b)) (cadddr n))))

(defun cfsqrt (n)
  (cond ((cddr n)			;A non integer
	 (merror "Can't take square roots of non-integers yet"))
	((setq n (cadr n))))
  (setq n (sqcont n))
  (cond ((= $cflength 1)
	 (cons '(mlist simp) n))
	((do ((i 2 (f1+ i))
	      (a (copy (cdr n))))
	     ((> i $cflength) (cons '(mlist simp) n))
	   (setq n (nconc n (copy a)))))))	

(defmfun $qunit (n)
  (let ((l (sqcont n)))
    (list '(mplus) (pelso1 l 0 1) 
	  (list '(mtimes) 
		(list '(mexpt) n '((rat) 1 2))
		(pelso1 l 1 0)))))

(defun pelso1 (l a b)
  (do ((i l (cdr i))) (nil)
    (and (null (cdr i)) (return b))
    (setq b (plus a (times (car i) (setq a b))))))

(defun sqcont (n)
  (prog (q q1 q2 m m1 a0 a l)
     (setq a0 ($isqrt n) a (list a0) q2 1 m1 a0 
	   q1 (*dif n (times m1 m1)) l (times 2 a0))
     a	(setq a (cons (*quo (plus m1 a0) q1) a))
     (cond ((equal (car a) l)
	    (return (nreverse a))))
     (setq m (*dif (times (car a) q1) m1)
	   q (plus q2 (times (car a) (*dif m1 m)))
	   q2 q1 q1 q m1 m)
     (go a)))

(defun ratcf (x y)
  (prog (a b)
   a	(cond ((equal  y 1) (return (nreverse (cons x a))))
	      ((minusp x)
	       (setq b (plus y (remainder x y))
		     a (cons (sub1 (*quo x y)) a)
		     x y y b))
	      ((greaterp y x)
	       (setq a (cons 0 a))
	       (setq b x x y y b))
	      ((equal x y) (return (nreverse (cons 1 a))))
	      ((setq b (remainder x y))
	       (setq a (cons (*quo x y) a) x y y b)))
   (go a)))

(defmfun $cfexpand (x)
  (cond ((null ($listp x)) x)
	((cons '($matrix) (cfexpand (cdr x))))))

(defun cfexpand (ll)
  (do ((p1 0 p2)
       (p2 1 (simplify (list '(mplus) (list '(mtimes) (car l) p2) p1)))
       (q1 1 q2)
       (q2 0 (simplify (list '(mplus) (list '(mtimes) (car l) q2) q1)))
       (l ll (cdr l)))
      ((null l) (list (list '(mlist) p2 p1) (list '(mlist) q2 q1)))))

;;(declare-top (splitfile sum)
;;	 (*expr sum))

;;(comment Summation stuff)

(defun adsum (e) (setq sum (cons (simplify e) sum)))

(defun adusum (e) (setq usum (cons (simplify e) usum)))

(defmfun simpsum2 (exp i lo hi)
  (prog (*plus *times $simpsum u)
     (setq *plus (list 0) *times 1)
     (when (or (and (eq hi '$inf) (eq lo '$minf))
	       (equal 0 (m+ hi lo)))
       (setq $simpsum t lo 0)
       (setq *plus (cons (m* -1 *times (maxima-substitute 0 i exp)) *plus))
       (setq exp (m+ exp (maxima-substitute (m- i) i exp))))
     (cond ((and (null $sumhack)
		 (eq ($sign (setq u (m- hi lo))) '$neg))
	    (cond ((equal u -1) (return 0))
		  (t (merror "Lower bound to sum is > upper bound"))))
	   ((free exp i)
	    (return (m+l (cons (freesum exp lo hi *times) *plus))))

	   ((setq exp (sumsum exp i lo hi))
	    (setq exp (m* *times (dosum (cadr exp) (caddr exp)
					(cadddr exp) (cadr (cdddr exp)) t))))
	   (t (return (m+l *plus))))
     (return (m+l (cons exp *plus)))))

(defun sumsum (e *var* lo hi)
  (let (sum usum)
    (cond ((eq hi '$inf)
	   (cond (*infsumsimp (isum e))
		 ((setq usum (list e))))) 
	  ((sum e 1)))
    (cond ((eq sum nil)
	   (return-from sumsum (list '(%sum) e *var* lo hi))))
    (setq *plus
	  (nconc (mapcar 
		  #'(lambda (q) (simptimes (list '(mtimes) *times q) 1 nil))
		  sum)
		 *plus))
    (and usum (setq usum (list '(%sum) (simplus (cons '(plus) usum) 1 t) *var* lo hi)))))

(defun sum (e y)
  (cond ((null e))
	((free e *var*)
	 (adsum (m* y e (m+ hi 1 (m- lo)))))
	((poly? e *var*)
	 (adsum (m* y (fpolysum e))))
	((eq (caar e) '%binomial) (fbino e y))
	((eq (caar e) 'mplus)
	 (mapc #'(lambda (q) (sum q y)) (cdr e)))
	((and (or (mtimesp e) (mexptp e) (mplusp e))
	      (fsgeo e y)))
	(t
	 nil
	 ;;	 #-cl
	 ;;	 (let (*a *n)
	 ;;	     (cond ((prog2 (m2 e '((mtimes) ((coefftt) (var* (set) *a freevar))
	 ;;					    ((coefftt) (var* (set) *n true)))
	 ;;			       nil)
	 ;;			   (not (equal *a 1)))
	 ;;		    (sum *n (list '(mtimes) y *a)))
	 ;;		   ((and (not (atom
	 ;;			       (setq *n
	 ;;				     ($ratdisrep
	 ;;				      (let (genvar (varlist (cons *var* nil)))
	 ;;					(ratrep* *n))))))
	 ;;			 (not (equal *n e))
	 ;;			 (not (eq (caar *n) 'mtimes)))
	 ;;		    (sum *n (list '(mtimes) y *a)))
	 ;;		   (t (adusum (list '(mtimes) e y)))))
	 )))

(defun isum (e)
  (cond ((memq (setq e (catch 'isumout (isum1 e))) '($inf $undefined $minf))
	 (setq sum (list e) usum nil))))

(defun isum1 (e)
  (cond ((or (free e *var*) (atom e))
	 (throw 'isumout '$inf))
	((ratp e *var*)
	 (adsum (ipolysum e)))
	((eq (caar e) 'mplus)
	 (mapc #'isum1 (cdr e)))
	( (isgeo e))
	((adusum e))))

(defun ipolysum (e)
  (ipoly1 ($expand e)))

(defun ipoly1 (e)
  (cond ((smono e *var*)
	 (ipoly2 *a *n (asksign (simplify (list '(mplus) *n 1)))))
	((mplusp e)
	 (cons '(mplus) (mapcar #'ipoly1 (cdr e))))
	(t (adusum e)
	   0)))

(defun ipoly2 (a n sign)
  (cond ((memq (asksign lo) '($zero $negative))
	 (throw 'isumout '$inf)))
  (and (null (equal lo 1))
       (adsum `((%sum) 
		((mtimes) ,a -1 ((mexpt) ,*var* ,n))
		,*var* 1 ((mplus) -1 ,lo))))
  (cond ((eq sign '$negative)
	 (list '(mtimes) a ($zeta (meval (list '(mtimes) -1 n)))))
	((throw 'isumout '$inf))))

(defun fsgeo (e y)
  (let ((r ($ratsimp (div* (maxima-substitute (list '(mplus) *var* 1) *var* e) e))))
    (cond ((free r *var*)
	   (adsum 
	    (list '(mtimes) y
		  (maxima-substitute 0 *var* e)
		  (list '(mplus)
			(list '(mexpt) r (list '(mplus) hi 1))
			(list '(mtimes) -1 (list '(mexpt) r lo)))
		  (list '(mexpt) (list '(mplus) r -1) -1)))))))

(defun isgeo (e)
  (let ((r ($ratsimp (div* (maxima-substitute (list '(mplus) *var* 1) *var* e) e))))
    (and (free r *var*)
	 (isgeo1 (maxima-substitute lo *var* e)
		 r (asksign (simplify (list '(mplus) (list '(mabs) r) -1)))))))

(defun isgeo1 (a r sign)
  (cond ((eq sign '$positive)
	 (cond ((mgrp a 0) (throw 'isumout '$inf))
	       ((throw 'isumout '$minf))))
	((eq sign '$zero)
	 (throw 'isumout '$undefined))
	((eq sign '$negative)
	 (adsum (list '(mtimes) a
		      (list '(mexpt) (list '(mplus) 1 (list '(mtimes) -1 r)) -1))))))

(defun fpolysum (e)			;returns *ans*
  (let ((a (fpoly1 (setq e ($expand ($ratdisrep ($rat e *var*))))))
	(b) ($prederror))
    (cond ((null a) 0)
	  ((zl-member lo '(0 1))
	   (maxima-substitute hi 'foo a))
	  ((or (equal t (mevalp (list '(mgeqp) lo 0)))
	       (memq (asksign lo) '($zero $positive)))
	   (list '(mplus) (maxima-substitute hi 'foo a)
		 (list '(mtimes) -1 (maxima-substitute (list '(mplus) lo -1) 'foo a))))
	  (t
	   (setq b (fpoly1 (maxima-substitute (list '(mtimes) -1 *var*) *var* e)))
	   (list '(mplus) (maxima-substitute hi 'foo a) (maxima-substitute lo 'foo b))))))

(defun fpoly1 (e)
  (cond ((smono e *var*)
	 (fpoly2 *a *n e))
	((eq (caar e) 'mplus)
	 (cons '(mplus) (mapcar #'fpoly1 (cdr e))))
	(t (adusum e) 0)))

(defun fpoly2 (a n e)
  (cond ((null (and (integerp n) (greaterp n -1))) (adusum e) 0)
	((equal n 0)
	 (m* (cond ((signp e lo)
		    (m1+ 'foo))
		   (t 'foo))
	     a))
	(($ratsimp
	  (m* a (list '(rat) 1 (f1+ n))
	      (m- ($bernpoly (m+ 'foo 1) (f1+ n))
		  ($bern (f1+ n))))))))

(defun fbino (e y)
  (prog (n d l h fl)
     (cond ((null (setq n (m2 (cadr e) (list 'n 'linear* *var*) nil)))
	    (return (adusum e))))
     (setq n (cdr (assq 'n n)))
     (cond ((null (setq d (m2 (caddr e) (list 'd 'linear* *var*) nil)))
	    (return (adusum e))))
     (setq d (cdr (assq 'd d)))
     (cond ((equal (cdr n) (cdr d))
	    (setq d (cons (simplus (list '(mplus) (car n) 
					 (list '(mtimes) -1 (car d))) 1 nil) 0))))
     (cond ((and (numberp (cdr d)) (or (minusp (cdr d)) (and (zerop (cdr d))
							     (numberp (cdr n)) (minusp (cdr n)))))
	    (rplacd d (minus (cdr d)))
	    (rplacd n (minus (cdr n)))
	    (setq l (simptimes (list '(mtimes) hi -1) 1 nil)
		  h (simptimes (list '(mtimes) lo -1) 1 nil)))
	   (t (setq l lo  h hi)))
     (cond ((null (or (zl-member (cdr n) '(0 -1)) (equal 0 (cdr d))))
	    (return (adusum e)))
	   ((and (equal 0 (cdr d)) (equal 1 (cdr n)))
	    (return (adsum (list '(mplus) (list '(%binomial)
						(list '(mplus) h (car n) 1) (list '(mplus) (car d) 1))
				 (list '(mtimes) -1 (list '(%binomial)
							  (list '(mplus) l (car n)) (list '(mplus) (car d) 1)))))))
	   ((equal 1 (cdr d))
	    (cond ((equal -1 (cdr n))
		   (setq fl 0))))
	   ((and (equal 2 (cdr d)) (equal 0 (cdr n)))
	    (setq fl 1))
	   ((return (adusum e))))
     (setq n (car n))
     (cond ((equal (cdr d) -1)
	    (setq d (simplus (list '(mplus) n (list '(mtimes) -1 (car d))) 1 nil)))
	   ((setq d (car d))))
     (cond ((equal fl 1) (setq d (*quo d 2))))
     (setq l (simplus (list '(mplus) l d) 1 nil)
	   h (simplus (list '(mplus) h d) 1 nil))
     (cond ((or (null (numberp l)) 
		(null
		 (or (numberp (setq d (simplus (list '(mplus) h (list '(mtimes) -1 n)) 1 nil)))
		     (and (numberp (simplus (list '(mplus) n (list '(mtimes) -2 h)) 1 nil))
			  (progn (setq fl 2) t)))))
	    (return (adusum e))))
     (setq e (list '(%binomial) n *var*))
     (and (greaterp l 0) (adsum (dosum (list '(mtimes) y -1 e) *var* 0 (sub1 l) t)))
     (and (lessp d 0)
	  (adsum (dosum (list '(mtimes) y -1 e) *var* (simplus (list '(mplus) h 1) 1 nil) n t)))
     (and (greaterp d 0)
	  (adsum (dosum (list '(mtimes) y e) *var* (simplus (list '(mplus) n 1) 1 nil) h t)))
     (setq fl
	   (cond ((null fl) (list '(mexpt) 2 n))
		 ((zerop fl) ($fib (simplus (list '(mplus) n 1) 1 nil)))
		 ((list '(mexpt) 2 (list '(mplus) n -1)))))
     (adsum (list '(mtimes) y fl))))

;;(declare-top (splitfile prodct))

;;(comment product routines)

(defmspec $product (l) (setq l (cdr l))
	  (cond ((not (= (length l) 4)) (merror "Wrong no. of args to product"))
		((dosum (car l) (cadr l)   (meval (caddr l)) (meval (cadddr l)) nil))))

(declare-top (special $ratsimpexpons))

;; Is this guy actually looking at the value of its middle arg?

(defun simpprod (x y z)
  (let (($ratsimpexpons t))
    (cond ((equal y 1)
	   (setq y (simplifya (cadr x) z)))
	  ((setq y (simptimes (list '(mexpt) (cadr x) y) 1 z)))))
  (simpprod1 y (caddr x)
	     (simplifya (cadddr x) z)
	     (simplifya (cadr (cdddr x)) z)))

(defun simpprod1 (exp i lo hi)
  (let (u)
    (cond ((not (symbolp i)) (merror "Bad index to product:~%~M" i))
	  ((alike1 lo hi)
	   (let ((valist (list i)))
	     (mbinding (valist (list hi))
		       (meval exp))))
	  ((and (null $prodhack)
		(eq ($sign (setq u (m- hi lo))) '$neg))
	   (cond ((eq ($sign (add2 u 1)) '$zero) 1)
		 (t (merror "Lower bound to product is > upper bound."))))
	  ((atom exp)
	   (cond ((null (eq exp i))
		  (power* exp (list '(mplus) hi 1 (list '(mtimes) -1 lo))))
		 ((let ((lot (asksign lo)))
		    (cond ((equal lot '$zero) 0)
			  ((eq lot '$positive)
			   (m// (list '(mfactorial) hi)
				(list '(mfactorial) (list '(mplus) lo -1))))
			  ((m* (list '(mfactorial)
				     (list '(mabs) lo))
			       (cond ((memq (asksign hi) '($zero $positive))
				      0)
				     (t (prog2 0
					    (m^ -1 (m+ hi lo 1))
					  (setq hi (list '(mabs) hi)))))
			       (list '(mfactorial) hi))))))))
	  ((list '(%product simp) exp i lo hi)))))

;;(declare-top (splitfile tayrat))

(defmfun $taytorat (e)
  (cond ((mbagp e) (cons (car e) (mapcar #'$taytorat (cdr e))))
	((or (atom e) (not (memq 'trunc (cdar e)))) (ratf e))
	((catch 'srrat (srrat e))) 
	(t (ratf ($ratdisrep e)))))

(defun srrat (e)
  (cons (list 'mrat 'simp (caddar e) (cadddr (car e)))
	(srrat2 (cdr e))))

(defun srrat2 (e)
  (if (pscoefp e) e (srrat3 (terms e) (gvar e))))

(defun srrat3 (l *var*)
  (cond ((null l) '(0 . 1))
	((null (=1 (cdr (le l))))
	 (throw 'srrat nil))
	((null (n-term l))
	 (rattimes (cons (list *var* (car (le l)) 1) 1)
		   (srrat2 (lc l))
		   t))
	((ratplus
	  (rattimes (cons (list *var* (car (le l)) 1) 1)
		    (srrat2 (lc l))
		    t)
	  (srrat3 (n-term l) *var*)))))


(declare-top				;(splitfile deftay)
 (special $props *i))

(defmspec $deftaylor (l)
  (prog (fun series param op ops)
   a	(when (null (setq l (cdr l))) (return (cons '(mlist) ops)))
   (setq fun (meval (car l)) series (meval (cadr l)) l (cdr l) param () )
   (when (or (atom fun) 
	     (if (eq (caar fun) 'mqapply)
		 (or (cdddr fun)	; must be one parameter
		     (null (cddr fun))	; must have exactly one
		     (do ((subs (cdadr fun) (cdr subs)))
			 ((null subs)
			  (setq op (caaadr fun))
			  (when (cddr fun)
			    (setq param (caddr fun)))
			  '())
		       (unless (atom (car subs)) (return 't))))
		 (progn
		   (setq op (caar fun))
		   (when (cdr fun) (setq param (cadr fun)))
		   (or (and (oldget op 'op) (not (eq op 'mfactorial)))
		       (not (atom (cadr fun)))
		       (not (= (length fun) 2))))))
     (merror "Bad argument to `deftaylor':~%~M" fun))
   (when (oldget op 'sp2)
     (mtell "~:M being redefined in `deftaylor'.~%" op))
   (when param (setq series (subst 'sp2var param series)))
   (setq series (subsum '*index series))
   (putprop op series 'sp2)
   (when (eq (caar fun) 'mqapply)
     (putprop op (cdadr fun) 'sp2subs))
   (add2lnc op $props)
   (push op ops)
   (go a)))

(defun subsum (*i e) (susum1 e))

(defun susum1 (e)
  (cond ((atom e) e)
	((eq (caar e) '%sum)
	 (if (null (smonop (cadr e) 'sp2var))
	     (merror "Argument to `deftaylor' must be power series at 0.")
	     (subst *i (caddr e) e)))
	(t (recur-apply #'susum1 e))))

(declare-top				;(splitfile decomp)
 (special varlist genvar $factorflag $ratfac *p* *var* *l* *x*))

(defmfun $polydecomp (e v)
  (let ((varlist (list v))
	(genvar nil)
	*var* p den $factorflag $ratfac)
    (setq p (cdr (ratf (ratdisrep e)))
	  *var* (cdr (ratf v)))
    (cond ((or (null (cdr *var*))
	       (null (equal (cdar *var*) '(1 1))))
	   (merror "Second arg to `polydecomp' must be an atom"))
	  (t (setq *var* (caar *var*))))
    (cond ((or (pcoefp (cdr p))
	       (null (eq (cadr p) *var*)))
	   (setq den (cdr p)
		 p (car p)))
	  (t (merror "Cannot `polydecomp' a rational function")))
    (cons '(mlist)
	  (cond ((or (pcoefp p)
		     (null (eq (car p) *var*)))
		 (list (rdis (cons p den))))
		(t (setq p (pdecomp p *var*))
		   (do ((l
			 (setq p (mapcar #'(lambda (q) (cons q 1)) p))
			 (cdr l))
			(a))
		       ((null l)
			(cons (rdis (cons (caar p)
					  (ptimes (cdar p) den)))
			      (mapcar #'rdis (cdr p))))
		     (cond ((setq a (pdecpow (car l) *var*))
			    (rplaca l (car a))
			    (cond ((cdr l)
				   (rplacd l
					   (cons (ratplus
						  (rattimes
						   (cadr l)
						   (cons (pterm (cdaadr a) 1)
							 (cdadr a))
						   t)
						  (cons
						   (pterm (cdaadr a) 0)
						   (cdadr a)))
						 (cddr l))))
				  ((equal (cadr a)
					  (cons (list *var* 1 1) 1)))
				  (t (rplacd l (list (cadr a)))))))))))))


;;; POLYDECOMP is like $POLYDECOMP except it takes a poly in *POLY* format (as
;;; defined in SOLVE) (numerator of a RAT form) and returns a list of
;;; headerless rat forms.  In otherwords, it is $POLYDECOMP minus type checking
;;; and conversions to/from general representation which SOLVE doesn't
;;; want/need on a general basis.
;;; It is used in the SOLVE package and as such it should have an autoload
;;; property 

(defun polydecomp (p *var*)
  (let ($factorflag $ratfac)
    (cond ((or (pcoefp p)
	       (null (eq (car p) *var*)))
	   (cons p nil))
	  (t (setq p (pdecomp p *var*))
	     (do ((l (setq p
			   (mapcar #'(lambda (q) (cons q 1))
				   p))
		     (cdr l))
		  (a))
		 ((null l)
		  (cons (cons (caar p)
			      (cdar p))
			(cdr p)))
	       (cond ((setq a (pdecpow (car l) *var*))
		      (rplaca l (car a))
		      (cond ((cdr l)
			     (rplacd l
				     (cons (ratplus
					    (rattimes
					     (cadr l)
					     (cons (pterm (cdaadr a) 1)
						   (cdadr a))
					     t)
					    (cons
					     (pterm (cdaadr a) 0)
					     (cdadr a)))
					   (cddr l))))
			    ((equal (cadr a)
				    (cons (list *var* 1 1) 1)))
			    (t (rplacd l (list (cadr a))))))))))))



(defun pdecred (f h *var*)		;f = g(h(*var*))
  (cond ((or (pcoefp h) (null (eq (car h) *var*))
	     (equal (cadr h) 1)
	     (null (zerop (remainder (cadr f) (cadr h))))
	     (and (null (pzerop (caadr (setq f (pdivide f h)))))
		  (equal (cdadr f) 1)))
	 nil)
	(t (do ((q (pdivide (caar f) h) (pdivide (caar q) h))
		(i 1 (f1+ i))
		(*ans*))
	       ((pzerop (caar q))
		(cond ((and (equal (cdadr q) 1)
			    (or (pcoefp (caadr q))
				(null (eq (caar (cadr q)) *var*))))
		       (psimp *var* (cons i (cons (caadr q) *ans*))))))
	     (cond ((and (equal (cdadr q) 1)
			 (or (pcoefp (caadr q))
			     (null (eq (caar (cadr q)) *var*))))
		    (and (null (pzerop (caadr q)))
			 (setq *ans* (cons i (cons (caadr q) *ans*)))))
		   (t (return nil)))))))

(defun pdecomp (p *var*)
  (let ((c (pterm (cdr p) 0))
	(a) (*x* (list *var* 1 1)))
    (cons (pcplus c (car (setq a (pdecomp* (pdifference p c)))))
	  (cdr a))))

(defun pdecomp* (*p*)
  (let ((a)
	(l (pdecgdfrm (pfactor (pquotient *p* *x*)))))
    (cond ((or (pdecprimep (cadr *p*))
	       (null (setq a (pdecomp1 *x* l))))
	   (list *p*))
	  (t (append (pdecomp* (car a)) (cdr a))))))

(defun pdecomp1 (prod l)
  (cond ((null l)
	 (and (null (equal (cadr prod) (cadr *p*)))
	      (setq l (pdecred *p* prod *var*))
	      (list l prod)))
	((pdecomp1 prod (cdr l)))
	(t (pdecomp1 (ptimes (car l) prod) (cdr l)))))

(defun pdecgdfrm (l)			;Get list of divisors
  (do ((l (copy-top-level l ))
       (ll (list (car l))
	   (cons (car l) ll)))
      (nil)
    (rplaca (cdr l) (f1- (cadr l)))
    (cond ((signp e (cadr l))
	   (setq l (cddr l))))
    (cond ((null l) (return ll)))))

(defun pdecprimep (x)
  (setq x (cfactorw x))
  (and (null (cddr x)) (equal (cadr x) 1))) 
       
(defun pdecpow (p *var*)
  (setq p (car p))
  (let ((p1 (pderivative p *var*))
	p2 p1p p1c a lin p2p)
    (setq p1p (oldcontent p1)
	  p1c (car p1p) p1p (cadr p1p))
    (setq p2 (pderivative p1 *var*))
    (setq p2p (cadr (oldcontent p2)))
    (and (setq lin (testdivide p1p p2p))
	 (null (pcoefp lin))
	 (eq (car lin) *var*)
	 (list (ratplus
		(rattimes (cons (list *var* (cadr p) 1) 1)
			  (setq a (ratreduce p1c
					     (ptimes (cadr p)
						     (caddr lin))))
			  t)
		(ratdif (cons p 1)
			(rattimes a (cons (pexpt lin (cadr p)) 1)
				  t)))
	       (cons lin 1)))))

(declare-top (unspecial *mfactl *factlist donel nn* dn* splist ans var
			dict *var* *ans* a* *a *n *a*  hi lo
			*infsumsimp *times *plus sum usum makef gensim))
