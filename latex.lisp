
(defun latex-print-command (val command)
  (cond ((or (stringp val) (keywordp val))
	 (format nil command val))
	((symbolp val)
	 `(format nil ,command ,val))))

(defun latex-expand (lis cmd)
  (mapcar (lambda (x)
	    `(princ ,(latex-print-command x cmd) *stream*))
	  lis))
   

(defun latex-traverse-enviroment (expr)
  `((princ ,(latex-print-command (second expr) "\\begin{~a}")
	   *stream*)
    
    ,@(if (and (eq 2 (length (first (third expr))))
		(listp (first (third expr)))
		(listp (second (third expr))))
	 (nconc 
	  (latex-expand (first (third expr)) "[~a]")
	  (latex-expand (second (third expr)) "{~a}"))
	 (latex-expand (third expr) "{~a}"))
    ,@(mapcar 'latex-traverse (butlast expr 3))
   	    
    (princ ,(latex-print-command (second expr) "\\end{~a}")
	   *stream*)))
    
(defun latex-command (command)
  (cons
   `(princ ,(latex-print-command (first command) "\\~a") *stream*)
   (latex-expand (rest command) "{~a}")))

(defun latex-traverse (expr)
  (cond ((or (symbolp expr) (stringp expr))
	 `(princ ,expr *stream*))
	((and (listp expr)
	      (keywordp (first expr)))
	 (latex-command expr))
	((listp expr)
	 (case (first expr)
	   (env (latex-traverse-enviroment expr))
	   (esc `(princ (latex-esc ,@(rest expr)) *stream*))))))
	   
	

(defmacro with-latex-output ((stream) &body expr)
  `(let ((*stream* ,stream))
     ,@(mapcan 'latex-traverse expr)))

;;test

(with-latex-output (*standard-output*)
  (:documentclass "scrreprt")
  (:Latex)
  (env :document ()
       (:textbf "My First Example Latex")))
       
  