(in-package :cl-latex)

(defun latex-print-command (val command)
  (cond ((stringp val)
	 (format nil command val))
	((keywordp val)
	 (latex-print-command  (string-downcase (symbol-name val)) command))
	((symbolp val)
	 `(format nil ,command ,val))
	));(T (latex-traverse val))))

(defun latex-expand (lis cmd)
  (mapcar (lambda (x)
	    `(princ ,(latex-print-command x cmd) stream))
	  lis))
   

(defun latex-traverse-enviroment (expr)
  `((princ ,(latex-print-command (second expr) "~%\\begin{~a}~%")
	   stream)
    
    ,@(if (and (eq 2 (length (first (third expr))))
		(listp (first (third expr)))
		(listp (second (third expr))))
	 (nconc 
	  (latex-expand (first (third expr)) "[~a]")
	  (latex-expand (second (third expr)) "{~a}"))
	 (latex-expand (third expr) "{~a}"))
    ,@(mapcan 'latex-traverse (cdddr  expr))
   	    
    (princ ,(latex-print-command (second expr) "~%\\end{~a}~%")
	   stream)))
    
(defun latex-command (command)
  (cons
   `(princ ,(latex-print-command (first command) "\\~a") stream)
   (append (latex-expand (rest command) "{~a}")
	   '((princ " " stream)))))
  

(defun latex-esc-char (c)
  (declare (optimize speed space))
  (case c 
    (#\& "\\&")
    (#\% "\\%")
    (#\# "\\#")
    (#\_ "\\_")
    (#\{ "\\{")
    (#\} "\\}")	 
    (T c)))

(defun latex-esc (str)
  (declare (optimize speed))
  (with-output-to-string (var)
    (map 'string 
	 (lambda (c) (princ (latex-esc-char c) var) c)
	 str)))

(defun latex-traverse (expr)
  (cond ((or (symbolp expr) (stringp expr))
	 `((princ ,expr stream)))
	((characterp expr)
	 `((princ ,(make-string 1 :initial-element expr) stream)))
	((and (listp expr)
	      (keywordp (first expr)))
	  (latex-command expr))
	((listp expr)
	 (case (first expr)
	   (env (latex-traverse-enviroment expr))
	   (esc (if (stringp (first (rest expr)))
		    `((princ ,(latex-esc (first (rest expr))) stream))
		    `((princ (latex-esc ,@(rest expr)) stream))))
	   (T (list expr))))
	(T (list expr))))
	   

(defun 	optimize-multiple-princ (lis &aux recur)
  (cond ((null lis) '())
	((eq 1 (length lis)) lis)
	((and (stringp (second (first lis)))
	      (stringp (second (second lis))))
	 (setq recur (optimize-multiple-princ (rest lis)))
	 (cons 
	  (list 'princ (concatenate 'string 
				    (second (first lis))
				    (second (first recur)))
		    'stream)
	  (rest recur)))
	 (T
	  (cons (first lis)
		(optimize-multiple-princ (rest lis))))))
			
(defmacro append-mapcar (&rest mapcar-args)
  `(apply 'append (mapcar ,@mapcar-args)))

(defmacro with-latex-output ((stream) &body expr)
  `(let ((stream ,stream))
     ,@(optimize-multiple-princ (append-mapcar 'latex-traverse expr))))

(defmacro latex (&rest expr)
  `(progn ,@(optimize-multiple-princ (append-mapcar 'latex-traverse expr))))