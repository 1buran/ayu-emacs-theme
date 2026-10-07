;;; ayu-dusk-theme.el --- Ayu dusk theme for Emacs  -*- lexical-binding: t; -*-

;; Copyright (C) 2026 buran

;; Author: buran
;; Version: 1.0.0
;; Keywords: faces themes
;; Package-Requires: ((emacs "29.1"))
;; Homepage: https://ayutheme.com/

;; This file is not part of GNU Emacs.

;;; Commentary:

;; The dusk Ayu theme, built from the official `mirage' palette of
;; <https://github.com/ayu-theme/ayu-colors>, which is what
;; <https://ayutheme.com/> calls "dusk": a dark theme with the light greys
;; pulled towards blue.
;;
;;   (load-theme 'ayu-dusk t)
;;
;; All the faces, the palettes and the options live in `ayu-themes.el'; see
;; its commentary and the README of this package.
;;
;; The other flavours are `ayu-night-theme' and `ayu-day-theme'.  Use
;; `M-x ayu-themes-load' or `M-x ayu-themes-cycle' to switch between them, and
;; `M-x ayu-themes-refresh' to rebuild the theme after changing an option.

;;; Code:

(eval-and-compile
  (when (not (featurep 'ayu-themes))
    ;; Load the core from this very directory even when it is not on
    ;; `load-path' yet.  `load-file-name' is nil while byte-compiling, so
    ;; fall back to the variables that do name the file being processed.
    (let* ((file (or load-file-name buffer-file-name
                     (bound-and-true-p byte-compile-current-file)))
           (dir (and file (file-name-directory file))))
      (when dir
        (add-to-list 'load-path (directory-file-name dir))))
    (require 'ayu-themes)))

;;;###autoload
(when (and (boundp 'custom-theme-load-path) load-file-name)
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(ayu-themes-define-theme ayu-dusk dusk
  "Ayu dusk: a soft, desaturated colour theme for Emacs.")

;;; ayu-dusk-theme.el ends here
