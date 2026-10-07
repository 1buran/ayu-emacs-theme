# Repository Guidelines

Contributor guide for `ayu-emacs-theme`, the three Ayu colour themes for GNU
Emacs (`ayu-night`, `ayu-dusk`, `ayu-day`) built from the official Ayu palette.

## Agent-Specific Instructions

- Never commit or push without explicit approval from the user. Prepare the
  changes, show what was done, and wait for the user's go-ahead.
- Before presenting changes, run the ert checks, byte-compile the whole package
  and make sure it reports **zero warnings**, then delete the `.elc` files again
  (`*.elc` is gitignored; a stale build must never shadow the source while the
  user is iterating).
- Then load-test all three flavours in batch: a successful load is also the
  check that every colour the faces ask for exists, because the `ayu` macro
  signals an error naming a missing palette entry. Re-run the duplicate check
  as well: two entries for the same face are legal but mean one of them is
  dead code.
- A colour must reach the face as a string, and anything built (a list, a plist)
  must be spliced into the backquoted spec with a comma. Emacs accepts neither
  mistake loudly: an uncommaed `(list ...)` or a list where a colour belongs
  turns into a face that is simply never rendered. `ayu-themes-check.el` guards
  both; if you find a third shape of this family, add an invariant for it.
- Finish by reading the values off a real frame (see *What the batch checks do
  not catch*), not by trusting the batch run: everything above passes on specs
  that render nothing at all.
- Never "fix" contrast by editing palette values. The palettes are the official
  Ayu data (see [Provenance of the colours](#provenance-of-the-colours)) and the
  themes must match <https://ayutheme.com/>. Contrast is opt-in through the
  `ayu-themes-contrasted-*` options, which are off by default.
- Keep the face list written **once**. It is resolved against the palette being
  defined, so a new flavour means adding ~115 colour entries, never a second
  copy of the faces.
- Every face addition must go through the option-aware helpers
  (`ayu-themes--syntax`, `--comment`, `--foreground`, `--scale`, `--intense`,
  `--mode-line-border`) so that the toggles keep working everywhere.
- When adding entries to an existing `ayu-themes--faces-*` function, keep the
  trailing parens of the last line exactly as they are: the closing parens of
  the section list, the `let` and the `defun` live on that line. A dropped
  paren does not error out — it silently swallows the rest of the file. Always
  re-run the depth check below afterwards.
- Derive face names of a package from its `defface` forms, never by guessing a
  pattern: `nerd-icons` names its dark variant `nerd-icons-dred`, not
  `nerd-icons-redd`, and the `lsp-rust-analyzer-*`/`lsp-erlang-elp-*`
  modifier faces are generated per client. A wrong name is silently ignored.
- Do not reformat or re-wrap faces unrelated to your change: the file is one
  face per line by design, which keeps diffs reviewable.

## Project Structure

| File | Role |
| --- | --- |
| `ayu-themes.el` | The core: the three palettes, the options, the helpers, all 2196 faces and the commands. This is where nearly all the work happens. |
| `ayu-night-theme.el` | ~45 lines: requires the core and calls `ayu-themes-define-theme` for the `night` (official `dark`) palette. |
| `ayu-dusk-theme.el` | Same for `dusk` (official `mirage`). |
| `ayu-day-theme.el` | Same for `day` (official `light`). |
| `ayu-themes-check.el` | The invariant checks (ert): palette entries are plain hex strings, all flavours define the same faces, no spec attribute value is malformed. Run it before handing anything over. |
| `README.org` | User documentation: installation, options, contrast table, coverage. |
| `CHANGELOG.md` | Keep a Changelog, Semantic Versioning. |

There is no file called `ayu-theme.el` on purpose: `load-theme` looks for
`<name>-theme.el`, so a core carrying the theme name would show up as a bogus
`ayu` theme in `M-x load-theme`. This is the layout of `modus-themes`.

`ayu-themes.el` is organised as thirteen sections, one `defun` each, all of them
appended in `ayu-themes--face-specs`:

| Section | Faces | Covers |
| --- | --- | --- |
| `--faces-base` | 120 | core UI, selection, gutters, search, parens, diagnostics, widgets, minibuffer |
| `--faces-font-lock` | 65 | the whole `font-lock-*` set (tree-sitter uses it in Emacs 29+) and `tree-sitter-hl-face:*` |
| `--faces-lang` | 95 | sh, makefile, cperl, js2, typescript, rjsx, css, clojure, haskell, verilog, agda, ledger, rpm |
| `--faces-org` | 125 | org, its agenda and habits, org-modern, org-ref, outlines |
| `--faces-text` | 161 | markdown, rst, AUCTeX/font-latex/reftex, nxml/sgml, web-mode, Info/man, shr |
| `--faces-completion` | 162 | company, corfu, vertico, selectrum, ivy/counsel/swiper, helm, orderless, marginalia, embark, which-key, helpful |
| `--faces-diagnostics` | 114 | flycheck, flymake, flyspell, jinx, lsp-mode, lsp-ui, eglot, dap-mode |
| `--faces-vc` | 175 | diff, smerge, ediff, diff-hl, git-gutter, magit, forge, git-commit, vc-dir |
| `--faces-files` | 146 | dired and its extensions, treemacs, neotree, all-the-icons, nerd-icons, ibuffer, speedbar |
| `--faces-modeline` | 156 | mode/header line, tab-bar/tab-line, tabbar, centaur-tabs, powerline, spaceline, smart-mode-line, telephone-line, doom-modeline, mood-line, nano-modeline, keycast, solaire |
| `--faces-term` | 91 | ansi-color, term, vterm, eat, comint, eshell |
| `--faces-misc` | 249 | rainbow-delimiters, hl-todo, highlights, indent guides, wgrep, iedit, undo-tree, avy, calendar, elfeed, IRC, mail, alert |
| `--faces-extra` | 537 | the long tail, grouped by package: lsp-mode, doom-modeline, php-mode, magit, transient, diff-hl, go-mode, web-mode, flycheck, nerd-icons, projectile, rg/ripgrep, treemacs, dap-mode, geben, popup, hydra, gptel, salt-mode, worklog |

## Build, Test, and Development Commands

```sh
# 1. the invariant checks; everything below is a fallback when they are not
#    enough.  They catch the mistakes Emacs swallows silently (see below).
emacs -Q --batch -L . -l ayu-themes-check.el -f ert-run-tests-batch-and-exit

# 2. byte-compile everything; must be warning-free
emacs -Q --batch -L . -f batch-byte-compile ayu-themes.el ayu-*-theme.el ayu-themes-check.el
rm -f *.elc

# 3. load each flavour (also validates that every palette key a face uses exists)
emacs -Q --batch -L . --eval '(progn
  (add-to-list (quote custom-theme-load-path) default-directory)
  (dolist (th (quote (ayu-night ayu-dusk ayu-day)))
    (load-theme th t)
    (princ (format "%s ok\n" th))))'

# how many faces does a flavour define?
emacs -Q --batch -L . --eval '(progn (load "ayu-themes" nil t)
  (let ((ayu-themes--palette (alist-get (quote night) ayu-themes-palettes)))
    (princ (format "%d faces\n" (length (ayu-themes--face-specs))))))'

# duplicate faces (should print nil)
emacs -Q --batch -L . --eval '(progn (require (quote cl-lib)) (load "ayu-themes" nil t)
  (let* ((ayu-themes--palette (alist-get (quote night) ayu-themes-palettes))
         (names (mapcar (quote car) (ayu-themes--face-specs))))
    (princ (format "%S\n" (cl-remove-duplicates
                           (cl-remove-if-not (lambda (n) (> (cl-count n names) 1)) names))))))'

# paren depth at every `;;; ` section boundary; all must be 0, including EOF
emacs -Q --batch --eval '(with-temp-buffer
  (insert-file-contents "ayu-themes.el") (goto-char (point-min))
  (let ((depth 0) (line 1))
    (while (not (eobp))
      (let ((ch (char-after)))
        (cond ((eq ch ?\n) (forward-char) (setq line (1+ line))
               (when (looking-at ";;; ")
                 (princ (format "line %4d depth %d\n" line depth))))
              ((eq ch ?\;) (end-of-line))
              ((eq ch ?\") (forward-char)
               (while (and (not (eobp)) (not (eq (char-after) ?\")))
                 (if (eq (char-after) ?\\) (forward-char 2) (forward-char 1)))
               (forward-char))
              ((eq ch ?\() (setq depth (1+ depth)) (forward-char))
              ((eq ch ?\)) (setq depth (1- depth)) (forward-char))
              (t (forward-char)))))
    (princ (format "EOF depth %d\n" depth))))'
```

### Coverage audit

A face that a package defines but the theme does not style silently falls back
to the default foreground, so coverage has to be measured, not eyeballed.
Collect every `defface` from the installed packages and subtract the faces the
theme sets:

```sh
# 1. the faces the theme styles
#    (note: inside the shell quotes use (quote f), not #'f -- the backslash of
#    #' survives the single quotes and breaks the command)
emacs -Q --batch -L . --eval '(progn (load "ayu-themes" nil t)
  (let ((ayu-themes--palette (alist-get (quote night) ayu-themes-palettes)) names)
    (dolist (e (ayu-themes--face-specs)) (push (symbol-name (car e)) names))
    (with-temp-file "/tmp/ayu-faces.txt"
      (insert (mapconcat (quote identity) (sort names (quote string<)) "\n")))))'

# 2. the faces the installed packages define, minus the ones above
export LC_ALL=C                      # one collation for sort and comm
grep -rhoE '^\(defface [a-zA-Z0-9:/+*._!?<>=-]+' ~/.emacs.d/straight/repos \
     --include='*.el' | sed 's/^(defface //' | sort -u > /tmp/all-faces.txt
sort -u /tmp/ayu-faces.txt > /tmp/ayu-sorted.txt
comm -23 /tmp/all-faces.txt /tmp/ayu-sorted.txt | wc -l
```

State at the time of writing: 898 third-party faces installed, 2196 styled,
**45 unstyled**, and the whole remainder is accounted for:

| Repository | Faces | What they are |
| --- | --- | --- |
| `themes` (doom-themes) | 12 | faces of another theme, not of a mode |
| `modus-themes` | 8 | idem |
| `timu-spacegrey-theme` | 6 | idem |
| `bui.el` | 9 | the UI library of `helm-bufler`-style packages |
| `llama` | 5 | a λ-calculus toy mode |
| `straight.el` | 2 | process output of the package manager |
| `s.el` | 2 | `ert` result faces, misattributed by the grep |
| `emacs-request` | 1 | `ee:face-example`, a docstring example |

In other words, every face that belongs to a real mode or UI package is covered.
Re-run the audit after touching the face list to prove nothing regressed.

### What the batch checks do not catch

The checks above cover the specs as data. What they cannot do is render, and
batch Emacs has no real frame, so `face-attribute` returns `unspecified` there.
Two mistakes were already shipped this way and both looked perfect in batch:

- **A malformed colour.** The `ayu` macro resolved the palette with `cdr`
  instead of `cadr`, so every colour was a one element list instead of a string.
  All three themes loaded, `custom-theme-set-faces` accepted the specs, and
  nothing was coloured anywhere: the faces were silently ignored, `C-x C-f`
  even failed with `wrong-type-argument stringp ("#10141c")`. `M-x
  load-theme` says nothing about it — the only trace is the harmless looking
  `Invalid face reference: class` in `*Messages*`.
- **An unevaluated form inside a spec.** `:box (list :line-width 1 :color ...)`
  written inside the backquoted spec stays a literal list whose first element is
  the symbol `list`, and Emacs refuses the face with
  `Invalid face box: list, :line-width, 1, :color, ...`.
  Build such a value outside the backquote (see `ayu-themes--box`) and splice it
  with a comma.

So, after the checks pass, look at a real frame once. With a running daemon
that is one command, no restart needed — this is also the fastest way to test a
change while the user has Emacs open:

```sh
# rebuild the theme in the running Emacs and read the real values
emacsclient -e '(progn (load "/path/to/ayu-themes.el") (load-theme (quote ayu-night) t)
                       (face-attribute (quote fill-column-indicator) :foreground))'
```

`(load "ayu-themes.el")` is required first: the spec functions are macro
expanded when the file is loaded, and `require` would be a no-op because the
theme files already loaded the feature. Then read the values on a frame that
has a display — with several frames, pass the frame explicitly, the daemon's
own initial frame has no colour support and legitimately reports `unspecified`:

```elisp
(let ((f (car (seq-filter (lambda (f) (> (or (ignore-errors (display-color-cells f)) 0) 0))
                          (frame-list)))))
  (list (face-attribute 'default :background f)
        (face-attribute 'font-lock-keyword-face :foreground f)))
```

What is genuinely left to the eye is only the aesthetic part: contrast on the
real terminal and the layout of the mode line.

## Provenance of the colours

This is the part of the project that must not drift.

- **Palettes.** Every hex value comes from the official
  [ayu-theme/ayu-colors](https://github.com/ayu-theme/ayu-colors) repository
  (`themes/dark.yaml`, `themes/mirage.yaml`, `themes/light.yaml`), resolved with
  its own generator. The resolved output is the `dist/generated/{dark,mirage,light}.js`
  files of the `ayu` npm package (v9.1.0 at the time of writing), which is what
  `designer/lib/shiki-theme.ts` is built on. Ayu stores colours in OKLCH with
  relative chroma, so the YAML cannot be read as hex by hand — do not try;
  re-derive from the published output instead.
- **Syntax mapping.** The scope table in the core's commentary comes from
  `designer/lib/shiki-theme.ts` in that same repository, i.e. the exact mapping
  <https://ayutheme.com/> renders its previews with. When a new scope appears,
  translate it through that file rather than inventing a colour.
- **Alpha colours** (selections, indent guides, find matches) are composited
  over the background they are drawn on: Emacs faces take opaque colours only.
- **`surface.sunk`** of the dark flavour is a near-black (`#010102`) in the
  official palette, which turns fringes and gutters into a black hole; the
  `night` flavour uses the classic ayu-dark background (`#0a0e14`) for that
  slot instead. This is the only deliberate deviation, and it is commented in
  the palette.
- The palettes are semantic: every entry has a name such as `bg-hl`,
  `fg-faint`, `syntax-keyword`, `orange-3`, plus the full official ramp of each
  hue (`orange-1` .. `orange-5`, darkest to lightest) and the 16 terminal
  colours. Faces never contain a literal hex value.

## Coding Style & Naming Conventions

- `lexical-binding: t`; `Package-Requires: ((emacs "29.1"))`. Emacs 29.1 is the
  real floor: the themes use the `font-lock-operator-face`,
  `font-lock-number-face`, `font-lock-property-name-face`,
  `font-lock-bracket-face` and friends that Emacs 29 added for tree-sitter.
- Public API uses the `ayu-themes-` prefix, internals `ayu-themes--`.
- `(ayu 'colour-name)` is the internal macro that pulls a value out of the
  palette being defined; it signals an error for an unknown entry, which is why
  a load is a sufficient validation of the palette usage.
- Every face uses the display spec `,c` = `((class color) (min-colors 89))`, so
  on a terminal without colour support the faces are left alone instead of being
  approximated into mud.
- Set `:extend t` on every face that paints a full-width background (region,
  `hl-line`, diff and smerge faces, blocks in org and markdown, tab bar).
- Faces go one per line; wrap to the existing indentation when an entry does not
  fit within 100 columns (the longest line in the file is 102 characters).
  Section functions use `(let ((c ayu-themes--class)) \`(...))`.
- `:box` accepts only `:line-width`, `:color` and `:style`; `:position` is not a
  box property (it belongs to `:underline`), and passing it is not an error —
  it is simply ignored, which is worse.
- Options are read when a theme is **defined**, so changing one requires
  rebuilding the enabled theme: `ayu-themes-refresh` (the `--toggle-*` commands
  call it themselves).

## Research Notes: what to copy and what not to

The themes were modelled on the state of the art, not on the first available
example. Keep these conclusions, they save a lot of time.

- **`timu-spacegrey-theme`** (the theme the port started from) is the widest
  Emacs theme in circulation and its package list is an excellent *checklist* —
  it is what the coverage of this repo was measured against. Its architecture,
  however, is a copy-paste: one 3740-line file with the dark flavour on lines
  409–2062 and the light flavour on 2063–3740, and the audit shows both blocks
  define **exactly the same 1267 face names, with zero faces unique to either
  flavour** — only the 25 `let`-bound colours differ. Adding a face means
  remembering to add it twice, and drift between the flavours is invisible. Use
  it as a source of *what to cover*, never as a source of *how to structure*.
- **`modus-themes`** is the architectural reference: an 8018-line core holding a
  single `modus-themes-faces` list written against semantic palette names, a
  `modus-themes-with-colors` macro that binds the palette while the list is
  evaluated, and 92-line theme files that only declare a palette. It also has
  palette overrides, colour preview commands and contrast checks.
- **`ef-themes`** is the same core with 40+ palettes of its own: each theme file
  is 239 lines and `(require 'modus-themes)`. Proof that "core + palette" scales
  to a whole family.
- This repository follows the modus layout at a much smaller scale: one core,
  one face list, three thin theme files. The one modus feature not ported yet is
  `ayu-themes-palette-overrides` (retune a single colour without touching the
  faces) — the natural next step if someone asks for it.

## Testing Guidelines

- The checks are executable: `ayu-themes-check.el` holds them as ert tests, and
  that is the first thing to run (`emacs -Q --batch -L . -l ayu-themes-check.el
  -f ert-run-tests-batch-and-exit`). Everything else in *Build, Test, and
  Development Commands* is a fallback or a one off. When a real mistake slips
  through, add a test for it before fixing it: it is the only thing that keeps
  the same class of bug from coming back, and both invariants in there were born
  that way.
- When adding an option, prove it does something: build the specs twice with the
  option off and on and diff the result, e.g.
  `(let ((ayu-themes--palette (alist-get 'night ayu-themes-palettes)))
  (cadr (assq 'font-lock-keyword-face (ayu-themes--face-specs))))` versus the
  same with `ayu-themes-contrasted-syntax` bound to `t`. The option test in
  `ayu-themes-check.el` only proves that the specs stay well formed.
- The option defaults are part of the contract: everything that changes a colour
  defaults to the original Ayu look (`nil`). `ayu-themes-italic-comments`
  defaults to `t` because Ayu itself sets `fontStyle: italic` on comments.
- Never trust a green batch run for a rendering question. See *What the batch
  checks do not catch*: read the values off a real frame with `emacsclient`,
  which works on the user's running daemon and needs no restart.

## Commit & Pull Request Guidelines

- Commit messages follow [Conventional
  Commits](https://www.conventionalcommits.org/en/v1.0.0/#specification):
  `type: description`, lowercase and imperative (e.g.
  `feat: add the dusk flavour`, `fix: stop the tab bar from eating the fringe`).
- Keep the commit subject within 50 characters.
- Wrap the commit body at 72 characters: hard-wrap every line at a word
  boundary, so no body line is longer than 72 characters.
- Split a change set into thematic commits by slicing what is already on disk:
  never roll the working tree back, hand-craft intermediate file states or
  rewrite commits to make every commit in the series stand on its own.
- A change to the face list and the matching README/CHANGELOG wording belongs to
  the same commit.

## Changelog & Releases

- `CHANGELOG.md` follows [Keep a
  Changelog](https://keepachangelog.com/en/1.1.0/) and the project follows
  [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
- Keep the `[Unreleased]` section at the top and add entries there as part of
  the change set. Categories, in this order: `Backward Incompatible Changes`,
  `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.
- The `Version:` header of `ayu-themes.el` (and of the three `ayu-*-theme.el`,
  which ship next to it) must match the newest released version in the
  changelog.
- Release by moving the `[Unreleased]` entries under a new
  `## [vX.Y.Z] - YYYY-MM-DD` heading, leaving `[Unreleased]` in place, then tag
  `main` with a lightweight tag and push it: `git tag vX.Y.Z` and
  `git push origin vX.Y.Z`. Do not move a published tag.
- A theme is a user-visible artefact, so any change to the colours or to the set
  of faces is at least a minor release; only documentation and comments are a
  patch.
