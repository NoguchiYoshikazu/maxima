;;; -*-  Mode: Lisp; Package: Maxima; Syntax: Common-Lisp; Base: 10 -*- ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     The data in this file contains enhancments.                    ;;;;;
;;;                                                                    ;;;;;
;;;  Copyright (c) 1984,1987 by William Schelter,University of Texas   ;;;;;
;;;     All rights reserved                                            ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     (c) Copyright 1980 Massachusetts Institute of Technology         ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "MAXIMA")
(macsyma-module algfac)

(comment this is the alg factor package) 
;;; Toplevel functions are: CPBGZASS CPTOM

(load-macsyma-macros ratmac)

(declare-top(*lexpr $factor)
	    (special tra* trl* *xn var intbs* plim many* split* alc ind p l)
	    (genprefix afc))


;; (DEFUN FIXMINPOLY NIL
;;        (PROG (ANS)
;; 	     (COND ((NOT (EQUAL (CADDR MINPOLY*) 1))
;; 		    (SETQ MPLC* (CADDR MINPOLY*))
;; 		    (SETQ MINPOLY* (PMONZ MINPOLY*))))
;; 	     (SETQ ANS (CDR MINPOLY*))
;; 	     (COND ((AND (EQUAL (CAR ANS) 2.)
;; 			 (EQUAL (CADR ANS) 1.)
;; 			 (EQUAL (CADDR ANS) 0.)
;; 			 (NOT (EQUAL 1.
;; 				     ((LAMBDA(MODULUS)
;; 					     (CMOD(MINUS (CADDDR ANS))))
;; 				      4.)))
;; 			 (CSQFRP (CADDDR ANS)))
;; 		    (SETQ INTBS* 1.))
;; 		   ((EQUAL (CDR ANS) '(1. 0. -1.)) (SETQ INTBS* 1.)))))


(defun ziredup (p)
  ((lambda (modulus alpha minpoly* algfac* gauss tellratlist many* mm* $gcd)
     (null (cddr(pfactor p))))
   nil nil nil nil nil nil nil 1. '$ez))

(defun intbasehk (p)
  (prog (modulus)
     (setq modulus plim)
     (setq p (pctimes intbs* p))
     (setq modulus nil)
     (return (car (ratreduce p intbs*))))) 

(defun findibase (p) 
  (prog (mainvar) 
     (setq mainvar (car p))
     (setq p (redresult p (pderivative p mainvar)))
     (setq p (cfactorw p))
     (setq mainvar 1.)
     loop (cond ((null p) (return mainvar)))
     (setq mainvar (times mainvar (expt (car p) (quotient (cadr p) 2.))))
     (setq p (cddr p))
     (go loop)))


(defun cpbgzass (qlist v m) 
  (prog (f y vj factors u w lc j p2 fnj fnq oldfac) 
     (cond ((equal m 1.) (return (list v)))
	   ((equal m (cadr v))  (return((lambda (var) (gfsplit v))
					(list var 1. 1.)))))
     (setq f (pmod v))
     (setq lc (caddr f))
     (setq f (monize f))
     (setq p2 1. qlist (cdr (nreverse qlist)))
     (setq oldfac (list nil f))
     nextq(setq v (car qlist))
     (setq qlist (cdr qlist))
     (setq j (findses v f))
     (setq oldfac (nconc oldfac fnq))
     (setq fnq nil)
     incrj(setq factors (nconc oldfac fnj))
     (setq fnj nil)
     (setq vj (pplus v (car j)) j (cdr j))
     tag2 (setq u (cadr factors))
     (setq w (pgcdu vj u))
     (cond ((or (numberp w) (and alpha (alg w))(= (cadr u) (cadr w))) (go nextfac)))
     (setq y (car (pmodquo u w)))
     (setq fnq (cons w fnq))
     (setq fnj (cons y fnj))
     (setq p2 (f1+ p2))
     (rplacd factors (cddr factors))
     (cond ((equal p2 m) (go out)) (t (go tag1)))
     nextfac
     (setq factors (cdr factors))
     tag1 (cond ((cdr factors) (go tag2)) (j (go incrj)) (qlist (go nextq)))
     out  (setq fnq (nconc fnq fnj (cdr oldfac)))
     (return (cons (ptimes lc (car fnq)) (cdr fnq))))) 


;; The function PMONZ used to be defined here.  It is also defined in
;; RAT;RAT3A and BMT claims the definitions are equivalent.

(defun findses (g f) 
  (prog (var tra* trl*) 
     (setq g (zassg (cdr g) (cdr f) (car g)))
     (setq var (list (car f) 1. 1.))
     (setq f (gfsplit g))
     (return (mapcar (function (lambda (a) (car (last a)))) f)))) 

(defun coefvec (p n vec) 
  (prog nil 
   loop (cond ((zerop n) (return vec)))
   (setq n (f1- n))
   (setq vec (cons (pterm p n) vec))
   (go loop))) 

(defun zassg (g f var) 
  (prog (i mat gn ans n) 
     (setq n (car f))
     (setq gn g)
     (setq i 1. mat (list (coefvec '(0. 1.) n (list 1.))))
     (go on)
     loop (setq i (add1 i))
     (setq gn (pgcd1 (ptimes1 gn g) f))
     on   (setq ans (lindep mat (coefvec gn n (list (list var i 1.)))))
     (cond (ans (return ans)))
     (go loop))) 

(defun divl (j a) (mapcar (function (lambda (l) (car (pmodquo l a)))) j)) 

;; (DEFUN PADDROWS (A B) (MAPCAR (FUNCTION PPLUS) A B))

(defun pdifrows (a b) (mapcar (function pdifference) a b)) 

(defun ptimesrow (var row) (mapcar (function (lambda (a) (ptimes var a))) row)) 

(defun ddiv (j) 
  (prog (a b) 
     (setq b j)
     ag   (setq a (car b))
     (cond ((zerop a) (setq b (cdr b)) (go ag)))
     (return (divl j a)))) 

(defun lindep (mat vec) 
  (prog (e d m row rowd vecd) 
     (setq m mat)
     (cond ((equal 0. (car vec)) (setq vec (cdr vec)))
	   (t (setq vec (pdifrows (cdr vec)
				  (ptimesrow (car vec) (cdar mat))))))
     loop (cond ((null (cdr m))
		 (cond ((zerolp (cdr (reverse vec)))
			(return (car (last vec))))
		       (t (rplacd m (cons (ddiv vec) (cdr m)))
			  (return nil)))))
     (setq row (cadr m))
     (setq rowd row vecd vec)
     loop1(setq d (car rowd))
     (setq e (car vecd))
     (cond ((equal 0. e)
	    (cond ((equal 0. d)
		   (setq vecd (cdr vecd) rowd (cdr rowd))
		   (go loop1))
		  (t (setq vec (cdr vec)) (setq m (cdr m)) (go loop))))
	   ((equal 0. d)
	    (rplacd m
		    (cons (divl vec e) (mapcar (function cdr) (cdr m))))
	    (return nil)))
     (setq vec (pdifrows (cdr vec) (ptimesrow e (cdr row))))
     (setq m (cdr m))
     (go loop)))

(defun gfsplit (f) 

  (prog (tr fl (n 0) ans tra* (i 0) nfl)
     (declare(fixnum n i))
     (setq fl (list f) n (cadr f))
     loop (cond ((null fl)(cond((null nfl)  
				(cond ((= n (length ans))(setq trl* nil)(return ans))(t (merror "`gfsplit'"))))(t(setq fl nfl nfl nil i (f1+ i))))))
     (setq f (car fl) fl (cdr fl))
     (cond((> i mm*) (merror "`gfsplit'")))

     (comment	     (cond ((and (null modulus) (not alpha) (equal 2. (cadr f)))
			    (setq ans (nconc ans (pfactorquad f)))
			    (go loop))))

     (setq tr (tracemod0 f i))
     (cond((or (pcoefp tr)(and algfac* (alg tr)))(setq nfl (cons f nfl))(go loop)))
     (setq f (cpbg0 tr f))
     (setq ans (nconc ans (car f)))
     (cond ((null (cdr f)) (go loop)))
     (setq nfl (nconc nfl (cdr f)))
     (go loop)))

(defun cpbg0 (tr f) 
  (prog (m f1 f2 g alc trm) 
     (setq m 0.)
     (cond ((and (not (numberp (caddr tr))) (alg (caddr tr)))
	    (setq alc (painvmod (caddr tr)) tr (ptimes alc tr)))
	   (t (setq alc 1.)))
     bk   (cond ((pcoefp f) (return
			      (cond ((and(null f1)(null f2))(merror "Wrong trace"))(t (cons f1 f2)))))
		((equal (cadr f) 1.) (return (cons (cons f f1) f2)))
		((equal m modulus)(return (cons f1 (cons f f2)))))
     (setq trm (pdifference tr (ptimes m alc)))
     (setq g (pgcdu trm f))
     (cond ((or (numberp g) (and alpha (alg g)))
	    (setq m (f1+ m))
	    (go bk)))
     (setq f (car (pmodquo f g)))
     (cond ((equal (cadr g) 1.) (setq f1 (cons g f1)))
	   (t (setq f2 (cons g f2))))
     (go bk)))

(defun cpol2p (p var)
  (prog((i 0) ans)
     (declare(fixnum i))
     (setq  p (nreverse p))
     loop (cond((null p) (return (cons var ans)))
	       ((equal 0.  (car p)) nil)
	       (t (setq ans (cons i(cons (car p) ans)))))
     (setq p (cdr p)i(f1+ i))(go loop)
     ))

(defun tracemod (v) 
  (prog (ans tr qlarge term) 
     (setq ans 0 tr (nreverse trl*) trl* nil)
     (cond ((and (atom (caar tr))(not (numberp (caar tr))))(setq qlarge t)))
     loop (cond((null tr)(return ans)))
     (setq term(cond (qlarge (car tr))(t (cpol2p(car tr)v))) tr (cdr tr))
     (setq ans (pplus ans term))
     (setq trl* (cons term trl*))
     (go loop)))

(defun otracemod (term q m prime) 
  (prog (ans i) 
     (setq ans term i 1. trl* (list term))
     loop (cond ((equal i m) (return ans)))
     (setq ans (pplus ans (setq term (pexptmod term prime q))))
     (setq trl* (cons term trl*))
     (setq i (f1+ i))
     (go loop)))

(defun tracemod0 (q i) 
  (declare(fixnum i))
  (prog ( l ans a dl) 
     (cond ((= i 0.)(return (cond (trl*(tracemod (car q)))
				  (t (otracemod var q mm* modulus)))))
	   (trl* (setq dl trl* trl* (mapcar (function (lambda(x)
					      (cons (car x) (pgcd1 (cdr x) (cdr q))))) trl*))))
     (cond (tra* (go tag))(t(setq l (cdr trl*) tra* (list alpha) a alpha)))
     loop(cond ((null l)(go tag)))
     (setq l (cdr l) a (pexpt a modulus) tra* (cons a tra*))
     (go loop)
     tag
     (setq ans(tracemod1 i tra* trl*))
     (cond (dl (setq trl* dl)))
     (return ans)
     ))

(defun tracemod1 (n a l)
  (prog(ans)
     (setq ans 0)
     loop     (cond ((null l)(return ans)))
     (setq ans (pplus ans (ptimes(pexpt (car a) n) (car l))))
     (setq l (cdr l) a (cdr a))(go loop) ))


;; The way arrays are manipulated has been changed to make this code reentrant.
;; Previously, arrays were kept on the array properties of symbols.  Now, the
;; symbols are bound to the arrays, so they can be rebound on re-entry.
;; The ANOTYPE, INVC, and FCTC arrays are set up in RAT;FACTOR.
;; 
;; (DECLARE (ARRAY* (NOTYPE A 2 INVC 1 FCTC 1)))

(declare-top (special anotype invc fctc))
(defmacro a (row col) `(arraycall t anotype ,row ,col))
(defmacro invc (ind) `(arraycall t invc ,ind))
(defmacro fctc (ind) `(arraycall t fctc ,ind))

(defun cptomexp (p m u n)
  (prog(b1 b2 j n-1 i l)
     (setq b1 (x**q1(list (car u) 1 1) u m p))
     (cond ((equal (cdr b1) '(1 1)) (setq split* t)(return nil)))
     (setq b2 b1 j 1. n-1 (f1- n))
     (go tag1)
     tag(setq j(f1+ j))
     (cond ((= j n)(return nil)))
     (setq b1 (pmodrem(ptimes b1 b2) u))
     tag1 (setq l (p2cpol b1 n-1) i n-1)
     sharp2   (cond ((null l) (go on)))
     (store (a j i) (car l))
     (setq l (cdr l))
     (setq i (f1- i))
     (go sharp2)
     on   (store (a j j) (pdifference (a j j) 1))
     (go tag)))

(defvar thr* 100.)

(defun cptom (p m u n) 
  #-multics (declare (fixnum n m  p))
  #+multics (declare (fixnum n m q i j))
  (prog (( q (expt p m)) l s *xn (j 0) (i 0) ind n-1)
     (declare (special q i j))
     (setq  n-1 (f1- n))
     (cond ((> q thr*) (return (cptomexp p m u n))))
     loop (setq j (f1+ j))
     (cond ((= j n) (return nil))
	   (ind (go sa))
	   (t
	    (setq *xn (mapcar #'pminus (p2cpol (cddr u) n-1))
		  s (x**q (p2cpol(list var 1 1) n-1) p m)
		  ind t)))
     (go st)
     sa (cptimesxa s q)
     st (cond ((and (= j 1)
		    (equal '(1 0) (ncdr s (f1- (length s) )))
		    (= 1 (length (zl-delete 0 (copy s)))))
	       (return (setq split* t))))
     (setq l s)
     (setq i n-1)
     (comment(print l))
     sharp2   (cond ((null l) (go on)))
     (store (a j i) (car l))
     (setq l (cdr l))
     (setq i (f1- i))
     (go sharp2)
     on   (store (a j j) (pdifference (a j j) 1))
     (go loop)))

(defun cptimesxa (p i) 
  (declare(fixnum i))
  (prog (xn q lc) 
   ag    (cond ((= i 0.) (return p)))
   (setq xn *xn q p lc (car p))
   loop (cond ((cdr q)
	       (rplaca q (pplus (cadr q) (ptimes lc (car xn))))
	       (setq q (cdr q) xn (cdr xn)))
	      (t (rplaca q (ptimes lc (car xn))) 
		 (setq i(f1- i))(go ag)))
   (go loop)))

(defun x**q (x p m) 
  #-multics (declare (fixnum   m p))
  #+multics (declare (fixnum d pp m i))
  (prog ((i 1)  (pp 1) (d 0))
     (declare (fixnum i pp d))
     (setq i 1. trl* (list x) pp 1.)
     loop (cond ((= i m) (return (cptimesxa x (f- (f* pp p) pp)))))
     (setq d pp)
     (cptimesxa x (f- (setq pp(f* pp p)) d))
     (setq trl* (cons(copy x) trl*))
     (setq i (f1+ i))
     (go loop)))

(defun cmnull (n) 
  (declare (fixnum n ))
  (prog (nullsp 	     (sub1n (f1- n)) mone (k 1) (j 0) (s 0) nullv (i 0) vj m aks)
     (declare (fixnum sub1n i j k s))
     (setq mone (cmod -1))
     sharp    (cond ((> i sub1n) (go on)))
     (store (fctc i) -1)
     (store (invc i) -1)
     (setq i (f1+ i))
     (go sharp)
     on   (setq k 1 nullsp (list 1))
     n2   (cond ((> k sub1n) (return nullsp)))
     (setq j 0)
     n3a  (cond ((> j sub1n) (go null))
		((or (equal (a k j) 0) (greaterp (fctc j) -1))
		 (setq j (f1+ j))
		 (go n3a)))
     (store (invc k) j)
     (store (fctc j) k)
     (setq m (a k j))
     (setq m (ptimes mone (painvmod m)))
     (setq s k)
     sharp1   (cond ((> s sub1n) (go on1)))
     (store (a s j) (ptimes m (a s j)))
     (setq s (f1+ s))
     (go sharp1)
     on1  (comment (go through columns))
     (setq s 0)
     sharp2   (cond ((> s sub1n) (go nextk)))
     (comment (go through rows in each column))
     (cond ((= s j) nil)
	   (t (prog (i) 
		 (setq aks (a k s))
		 (setq i k)
		 sharp3   (cond ((> i sub1n) (return nil)))
		 (store (a i s)
			(pplus (a i s)
			       (ptimes (a i j) aks)))
		 (setq i (f1+ i))
		 (go sharp3))))
     (setq s (f1+ s))
     (go sharp2)
     null (setq nullv nil)
     (setq s 0)
     sharp4   (cond ((> s sub1n) (go on4))
		    ((= s k) (setq nullv (cons s (cons 1 nullv))))
		    ((> (invc s) -1)
		     (setq vj (a k (invc s)))
		     (cond ((equal vj 0) nil)
			   (t (setq nullv (cons s (cons vj nullv))))))
		    )	     (setq s (f1+ s))
     (go sharp4)
     on4  (cond ((equal (car nullv) 0) (setq nullv (cadr nullv)))
		((setq nullv (cons var nullv))))
     (setq nullsp (cons nullv nullsp))
     nextk(setq k (f1+ k))
     (go n2)))

