;;; init.el --- the Emacs the vhs tapes drive  -*- lexical-binding: t; -*-

;; Loaded by the `record demo' task: the tape starts Emacs with
;; `emacsclient -c' and loads this file, on top of whatever configuration the
;; machine has, so that a recording shows a real Emacs: its line numbers, its
;; mode line, its language modes, its language servers.
;;
;; The theme comes from this checkout rather than from a copy that may be
;; installed somewhere: the root is put on `load-path' and on
;; `custom-theme-load-path', and `ayu-themes-load' disables the other Ayu
;; flavours and enables the one asked for.  The core is expected to be loaded
;; already; after an edit of `ayu-themes.el', reload it by hand -- the face
;; specs are macro expanded when the file is loaded.
;;
;; The snippets of demo/snippets are opened in a fixed order and `C-n' / `C-p'
;; walk through them, so a tape only has to press keys.  The tapes move the
;; cursor with the ordinary arrow keys -- that is what lights up the current
;; line number in the gutter.
;;
;; The flavour to show is read from demo/output/active.mode, and the flavour
;; that was enabled before it is written to demo/output/prev.mode, so a caller
;; can put the original theme back.  AYU_DEMO_ONLY narrows the run to a single
;; snippet, AYU_DEMO_SNIPPETS another directory of them, and AYU_DEMO_LOG a
;; file to write what the real terminal frame reports about the theme: batch
;; Emacs answers `unspecified' for every one of those values, so the recorded
;; frame is the only honest source for them.

;;; Code:

(defvar ayu-demo--dir (file-name-directory (or load-file-name buffer-file-name))
  "Directory of this file, i.e. demo/.")

(defvar ayu-demo--root (file-name-directory (directory-file-name ayu-demo--dir))
  "The repository root, one level above demo/.")

(setq inhibit-startup-screen t
      initial-scratch-message nil
      ring-bell-function #'ignore
      make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      minibuffer-message-timeout 0
      ;; A multi-line message -- the configuration, an LSP client, a warning --
      ;; would grow the echo area, shrink the window and leave the bottom of the
      ;; frame half repainted on a terminal.  The recording is about the window.
      resize-mini-windows nil)
(setq-default tab-width 4)              ; the Go snippet is indented with tabs
(blink-cursor-mode -1)
(dolist (mode '(menu-bar-mode tool-bar-mode scroll-bar-mode))
  (when (fboundp mode) (funcall mode -1)))

;; The echo area -- the line under the mode line -- is part of the recorded
;; frame, and a message stays in it until the next one arrives, so the frame
;; would end with the last thing the configuration had to say: `lsp-mode'
;; announcing the folders of every project that is open next to the snippets,
;; or the error of a key that cannot edit a read-only snippet.
;;
;; Two hooks are what a message of the frame goes through, and both are told
;; that it is already handled for as long as the recorded frame lives:
;;
;;   `set-message-function' is called with the text of every message, and a
;;   non-nil return value means the message was handled and is not displayed
;;   (it is still written to *Messages*, which is where the recording can be
;;   debugged); `command-error-function' is what a command error goes through.
;;
;; The one message neither hook can catch is the "Loading ..." banner of this
;; file itself: it is printed before the file is evaluated, so the tape binds
;; `inhibit-message' around the `load'.
;;
;; What has to be prevented rather than silenced is a *question*: a prompt is
;; read, not written, so it would stop the tape and wait for an answer.
;; `lsp-mode' asks one before it starts watching the files of a repository with
;; many directories (`lsp-enable-file-watchers').
;;
;; `resize-mini-windows' above keeps the echo area one line high even so.
(defvar ayu-demo--frame nil
  "The frame the recording is made in; the settings below are undone with it.")

(defvar ayu-demo--saved nil
  "The settings of the recorded frame, to put back when it is closed.")

(defun ayu-demo--restore ()
  "Put back whatever the demo changed for the recording."
  (dolist (cell ayu-demo--saved)
    (set (car cell) (cdr cell))))

(defun ayu-demo--restore-on-delete (frame)
  "Undo the changes of the demo once the recorded FRAME is closed."
  (when (eq frame ayu-demo--frame)
    (ayu-demo--restore)))

(setq ayu-demo--frame (selected-frame)
      ayu-demo--saved (delq nil (mapcar (lambda (var)
                                          (when (boundp var)
                                            (cons var (symbol-value var))))
                                        '(set-message-function
                                          command-error-function
                                          lsp-enable-file-watchers))))
;; Whatever is in the echo area already -- the "Loading ..." banner, when the
;; file was loaded without the tape, or a leftover of an earlier frame -- goes
;; before the hooks take over; `inhibit-message' is bound so that this clear
;; itself is not swallowed by the `let' of the tape.
(let ((inhibit-message nil)) (message nil))
(setq set-message-function (lambda (_message) t)
      command-error-function (lambda (&rest _) nil))
(when (boundp 'lsp-enable-file-watchers)
  (setq lsp-enable-file-watchers nil))

(add-hook 'delete-frame-functions #'ayu-demo--restore-on-delete)

;; The checkout wins over anything already on `load-path', and `load-theme' has
;; to be able to find the `ayu-*-theme.el' files next to the core.
(add-to-list 'load-path ayu-demo--root)
(add-to-list 'custom-theme-load-path ayu-demo--root)

;; Packages that only make the frame look like a working Emacs are taken from
;; the installation of the machine when it has them: the classic language modes
;; (go-mode, php-mode) and the mode line (doom-modeline with nerd-icons).  Only
;; the packages, never the configuration: a configuration drags its prompts, its
;; LSP clients and the paths of unrelated projects into the frame.
;; (dolist (dir '("~/.emacs.d/straight/repos/go-mode.el"
;;                "~/.emacs.d/straight/repos/php-mode/lisp"
;;                "~/.emacs.d/straight/repos/doom-modeline"
;;                "~/.emacs.d/straight/repos/nerd-icons.el"
;;                "~/.emacs.d/straight/repos/shrink-path.el"
;;                "~/.emacs.d/straight/repos/compat"
;;                "~/.emacs.d/straight/repos/s.el"
;;                "~/.emacs.d/straight/repos/f.el"
;;                "~/.emacs.d/straight/repos/dash.el"))
;;   (when (file-directory-p (expand-file-name dir))
;;     (add-to-list 'load-path (expand-file-name dir))))
;; (require 'go-mode nil t)
;; (require 'php-mode nil t)
;; (dolist (package '(nerd-icons doom-modeline))
;;   (require package nil t))
;; (when (fboundp 'doom-modeline-mode)
;;   (line-number-mode 1)
;;   (column-number-mode 1)
;;   (doom-modeline-mode 1))

;; The core of the checkout is loaded explicitly, and the command disables the
;; Ayu flavours that are already enabled -- a configuration normally loads one
;; of them.
;; (load (expand-file-name "ayu-themes.el" ayu-demo--root) nil t)
;; (ayu-themes-load (intern (or (getenv "AYU_THEME") "night")))

(let* ((current-dir (file-name-directory (or load-file-name (buffer-file-name))))
       (active-file (expand-file-name "output/active.mode" current-dir))
       (prev-file   (expand-file-name "output/prev.mode" current-dir))
       ;; 1. get the current active theme full name e.g. "ayu-dusk"
       (current-theme-str (symbol-name (or (car-safe custom-enabled-themes) 'ayu-night)))
       ;; 2. cut prefix "ayu-"
       (clean-theme-str (string-remove-prefix "ayu-" current-theme-str))
       ;; 3. read the theme name from output/active.mode
       (new-theme (if (file-exists-p active-file)
                      (with-temp-buffer
                        (insert-file-contents active-file)
                        (intern (string-trim (buffer-string))))
                    'night)))

  ;; 4. save clean theme name (without prefix "ayu-")
  (write-region clean-theme-str nil prev-file nil 'visit-nil)

  ;; 5. load and apply the new active theme
  (ayu-themes-load new-theme))

(defvar ayu-demo--names '("summer.go" "SummerLease.php" "summer-lease.js"
                          "summer.html" "summer_lease.py" "summer.sh"))
(defvar ayu-demo--buffers nil)
(defvar ayu-demo--index 0)

(let* ((only (getenv "AYU_DEMO_ONLY"))
       (names (if (and only (not (equal only ""))) (list only) ayu-demo--names))
       (dir (or (getenv "AYU_DEMO_SNIPPETS")
                (expand-file-name "snippets" ayu-demo--dir))))
  (setq ayu-demo--buffers
        (mapcar (lambda (name)
                  (let ((buf (find-file-noselect (expand-file-name name dir))))
                    (with-current-buffer buf
                      (setq buffer-read-only t)
                      ;; Numbers of lines and columns are what a screenshot of
                      ;; Emacs is expected to show; the language modes come from
                      ;; the checkout when it is a bare Emacs.
                      (column-number-mode 1)
                      (display-line-numbers-mode 1)
                      ;; Fontify up front: jit-lock would do it on the first
                      ;; redisplay, which is exactly the frame being recorded.
                      (font-lock-ensure))
                    buf))
                names)))

(defun ayu-demo--diag ()
  "Write what the real terminal frame reports about the theme."
  (let ((log (getenv "AYU_DEMO_LOG")))
    (when (and log (not (equal log "")))
      (with-temp-file log
        (insert (format "theme : %S\n" custom-enabled-themes))
        (insert (format "frame : %d cols x %d rows, %S colours\n"
                        (frame-width) (frame-height) (display-color-cells)))
        (insert (format "windows: %S\n" (mapcar #'window-buffer (window-list))))
        (dolist (face '(default cursor fringe line-number line-number-current-line
                                mode-line font-lock-keyword-face font-lock-string-face
                                font-lock-comment-face font-lock-function-name-face))
          (insert (format "%-28s fg %-12s bg %s\n" face
                          (face-attribute face :foreground nil t)
                          (face-attribute face :background nil t))))
        (insert "modes:\n")
        (dolist (buf ayu-demo--buffers)
          (insert (format "  %-18s %s%s\n" (buffer-name buf)
                          (with-current-buffer buf major-mode)
                          (if (bound-and-true-p display-line-numbers-mode)
                              ", line numbers" ""))))))))

(defun ayu-demo--log (tag)
  "Append the window layout to the log, when AYU_DEMO_LOG asks for one."
  (let ((log (getenv "AYU_DEMO_LOG")))
    (when (and log (not (equal log "")))
      (let ((inhibit-message t))        ; the echo area belongs to the recording
        (with-temp-buffer
          (insert (format "%-6s %s  windows: %S\n" tag (format-time-string "%T")
                          (mapcar (lambda (w) (list (buffer-name (window-buffer w))
                                                    (window-height w)))
                                  (window-list))))
          (append-to-file (point-min) (point-max) log))))))

(defun ayu-demo--window ()
  "The window the demo shows its snippet in: the main window of the frame.

The selected window is not it: a configuration may have popped something up --
a `*Warnings*' buffer, an LSP log, an inspector -- and that popup is selected
from then on, so the snippet would go to a small window at the bottom while the
main one keeps whatever it was showing."
  (or (and (fboundp 'window-main-window) (window-main-window))
      (car (window-list))
      (selected-window)))

(defun ayu-demo-show (n)
  "Show the N-th snippet in the main window of the frame."
  (setq ayu-demo--index (mod n (length ayu-demo--buffers)))
  (let ((buf (nth ayu-demo--index ayu-demo--buffers))
        (win (ayu-demo--window)))
    ;; Undo any split that appeared since the last snippet and make the keys
    ;; (the arrows of the tapes) act on the window that is on screen.
    (delete-other-windows win)
    (select-window win)
    (set-window-buffer win buf)
    (set-window-start win (point-min))
    (with-current-buffer buf (goto-char (point-min)))
    (force-mode-line-update))
  (ayu-demo--log "show"))

(defun ayu-demo-next () (interactive) (ayu-demo-show (1+ ayu-demo--index)))
(defun ayu-demo-prev () (interactive) (ayu-demo-show (1- ayu-demo--index)))

(define-key global-map (kbd "C-n") #'ayu-demo-next)
(define-key global-map (kbd "C-p") #'ayu-demo-prev)

(ayu-demo-show 0)
(ayu-demo--diag)
;; While AYU_DEMO_LOG is set, keep a trail of the window layout behind it: the
;; layout at the end of this file is not necessarily the one the recording ends
;; with, since anything may pop a window up while a tape is running.
(let ((log (getenv "AYU_DEMO_LOG")))
  (when (and log (not (equal log "")))
    (run-with-timer 1 2 (lambda () (ayu-demo--log "tick")))))
(message nil)

(provide 'ayu-demo)

;;; init.el ends here
