;;; ayu-themes-check.el --- Invariant checks for the ayu themes  -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Andrew Burdyug

;; This file is not part of GNU Emacs.

;;; Commentary:

;; The themes are a static table of face specs, so there is not much to test.
;; What there is must be tested though, because Emacs reports none of these
;; mistakes: a spec with a malformed colour is accepted without a word and the
;; face simply never renders.  That is not hypothetical -- resolving a palette
;; entry with `cdr' instead of `cadr' wrapped every colour in a one element
;; list, the themes loaded fine, and nothing was coloured anywhere.
;;
;;   emacs -Q --batch -L . -l ayu-themes-check.el -f ert-run-tests-batch-and-exit
;;
;; Loading a theme is still worth doing on top of this (it catches an unknown
;; palette entry, which the `ayu' macro signals), and a live frame is worth
;; looking at once, since batch Emacs has no display to render on.

;;; Code:

(require 'ert)
(require 'cl-lib)

(require 'ayu-themes)

(defconst ayu-themes-check--colour-attributes
  '(:foreground :background :overline :distant-foreground :distant-background)
  "Face attributes whose value has to be a colour string.")

(defconst ayu-themes-check--options
  '(ayu-themes-italic-comments
    ayu-themes-contrasted-comments
    ayu-themes-contrasted-syntax
    ayu-themes-contrasted-foreground
    ayu-themes-scale-org-headlines
    ayu-themes-org-intense-colors
    ayu-themes-mode-line-border)
  "The options that change what `ayu-themes--face-specs' returns.")

(defun ayu-themes-check--specs (flavour)
  "Return the face specs of FLAVOUR."
  (let ((ayu-themes--palette (alist-get flavour ayu-themes-palettes)))
    (ayu-themes--face-specs)))

(defconst ayu-themes-check--code-symbols
  '(list cons append quote function)
  "Symbols a value cannot start with, unless it is unevaluated code.
The face specs are built inside a backquote, so a bare `(list ...)'
in one of them is not a call: it stays a literal list in the spec and
Emacs rejects it at load time with a message that names the symbol,
e.g. \"Invalid face box: list, :line-width, 1, :color, ...\".")

(defun ayu-themes-check--malformed (flavour)
  "Return the malformed attribute values of FLAVOUR.
Each element is a list (FACE ATTRIBUTE VALUE).  A value counts as
malformed when

  - a colour attribute is neither a string nor `unspecified';
  - `:height' is not a number;
  - the value is a one element list holding a string, which is the
    shape a palette lookup gets when it takes the cdr of an alist
    entry instead of the cadr;
  - the value is an unevaluated form, i.e. a list starting with one
    of `ayu-themes-check--code-symbols'."
  (let (bad)
    (dolist (entry (ayu-themes-check--specs flavour))
      ;; An entry is (FACE SPEC): SPEC is the list of clauses in the cadr, and
      ;; a clause is (DISPLAY ATTRS-PLIST) -- the attributes are a proper list
      ;; of their own, so they live in the cadr of the clause.  Getting either
      ;; of these two levels wrong makes the walk below find nothing at all.
      (dolist (clause (cadr entry))
        (let ((attrs (cadr clause)))
          (while attrs
            (let ((attribute (car attrs))
                  (value (cadr attrs)))
              (when (or (and (consp value)
                             (stringp (car value))
                             (null (cdr value)))
                        (and (consp value)
                             (memq (car value) ayu-themes-check--code-symbols))
                        (and (memq attribute ayu-themes-check--colour-attributes)
                             (not (or (stringp value) (eq value 'unspecified))))
                        (and (eq attribute :height)
                             (not (numberp value))))
                (push (list (car entry) attribute value) bad)))
            (setq attrs (cddr attrs))))))
    (nreverse bad)))

(defun ayu-themes-check--flavour-entries (flavour)
  "Return the palette entry names of FLAVOUR."
  (mapcar #'car (alist-get flavour ayu-themes-palettes)))


;;; The palettes

(ert-deftest ayu-themes-check-palettes-hold-plain-hex-strings ()
  "Every palette entry is a \"#rrggbb\" string.
The palettes are alists of (NAME \"#rrggbb\") lists, so the value
is the `cadr' -- taking the `cdr' is the mistake this guards."
  (dolist (flavour ayu-themes-flavours)
    (dolist (entry (alist-get flavour ayu-themes-palettes))
      (should (stringp (cadr entry)))
      (should (string-match "\\`#[0-9a-fA-F]\\{6\\}\\'" (cadr entry))))))

(ert-deftest ayu-themes-check-palettes-share-their-entries ()
  "All flavours define exactly the same palette entries.
The face list is written once, so a colour added to one palette
only would break the other two at load time."
  (let ((reference (sort (ayu-themes-check--flavour-entries 'night) #'string<)))
    (dolist (flavour (cdr ayu-themes-flavours))
      (should (equal reference
                     (sort (ayu-themes-check--flavour-entries flavour) #'string<))))))

(ert-deftest ayu-themes-check-ansi-vector-is-plain ()
  "`ansi-color-names-vector' is a vector of colour strings."
  (dolist (flavour ayu-themes-flavours)
    (let* ((ayu-themes--palette (alist-get flavour ayu-themes-palettes))
           (vector (cadr (assq 'ansi-color-names-vector (ayu-themes--variables)))))
      (should (= 8 (length vector)))
      (should (cl-every #'stringp vector)))))


;;; The face specs

(ert-deftest ayu-themes-check-no-malformed-attribute-values ()
  "No face gets a colour that is not a string, in any flavour."
  (dolist (flavour ayu-themes-flavours)
    (should (equal nil (ayu-themes-check--malformed flavour)))))

(ert-deftest ayu-themes-check-options-do-not-malform-the-specs ()
  "Toggling an option on leaves every colour a plain string.
Every option is off by default, so flipping each one in turn
covers the `nil' and the non-nil branch of the whole feature."
  (dolist (option ayu-themes-check--options)
    (let ((original (symbol-value option)))
      (unwind-protect
          (progn
            (set option (not original))
            (dolist (flavour ayu-themes-flavours)
              (should (equal nil (ayu-themes-check--malformed flavour)))))
        (set option original)))))

(ert-deftest ayu-themes-check-flavours-define-the-same-faces ()
  "All flavours define the same faces, with the same spec shape."
  (let* ((faces (mapcar (lambda (flavour)
                          (mapcar #'car (ayu-themes-check--specs flavour)))
                        ayu-themes-flavours))
         (reference (car faces)))
    (dolist (other (cdr faces))
      (should (equal reference other)))))

(ert-deftest ayu-themes-check-no-duplicate-faces ()
  "No flavour defines the same face twice.
A duplicate is not an error -- the last entry wins -- but it means
one of the two is dead code."
  (dolist (flavour ayu-themes-flavours)
    (let ((names (mapcar #'car (ayu-themes-check--specs flavour))))
      (should (equal names (cl-remove-duplicates names :test #'eq))))))

(ert-deftest ayu-themes-check-every-face-uses-the-colour-display-spec ()
  "Every clause carries the `(min-colors 89)' display spec.
Emacs could render the hex values on a terminal with fewer colours,
but the themes are meant to be left alone there."
  (dolist (flavour ayu-themes-flavours)
    (dolist (entry (ayu-themes-check--specs flavour))
      (dolist (clause (cadr entry))
        (should (equal ayu-themes--class (car clause)))))))

(provide 'ayu-themes-check)
;;; ayu-themes-check.el ends here
