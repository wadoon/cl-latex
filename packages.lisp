(in-package :cl-user)

(defpackage :cl-latex
  (:use :cl)
  (:nicknames :tex)
  (:export :latex-esc :with-latex-output))

(pushnew :cl-latex *features*)
