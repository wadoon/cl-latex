(load "packages")
(load "latex")

(defun latex-hello-world (name)
  (cl-latex:with-latex-output (*standard-output*)
    (:documentclass "scrreprt")
    "\n"
    (:usepackage "graphicx")
    (:author name)
    (env :document ()
	 (env :center ()
	      (:textbf (esc name))))))



(cl-latex:with-latex-output (*standard-output*)
  (:documentclass "scrreprt")
  #\Newline
  (:a "b"))