# cl-latex  (0.1alpha)

This library produces latex code from s-expr similiar to cl-who for html.

    License: cc-by-sa 3.0
    Author:  Alexander Weigl <alexweigl@gmail.com>
    Date: 2011-07-08


## Example
    (with-latex-output (*standard-output*)
      (:documentclass "report")
      "\n"
      (:usepackage "xcolor")
      (:author "Lisp")
      (:date   today)
      (env :document ()
         (:textbf "My first document")
         (env :center ()
              "With \verb+esc+ you escape the latex characters: "
              (esc "& _ # { }"))))

## How it works:

	(with-latex-output (stream) &body latex-expression)
 
Every s-expr in *latex-expression* will be converted 
to a princ command. *stream* is a stream that should be used by princ.
A summary of *latex-expression* and the translation:


     (:command "A" "B" "C")          
                               => \command{A}{B}{C}
     (env :center ( ("A") ("B") ) …) 
                               => \begin{center}[A]{B} … \end{center}
     (esc "A & B")            
                               => A \& B

Every other s-expr is put into the output untouched.
A multiple print of literal strings will be optimize into one call to princ.
