# Ayu colour themes for GNU Emacs

This package ports the three [Ayu](https://ayutheme.com/) flavours to Emacs:

| Flavour | Official name | Background | Foreground |
|----------------|---------------|------------|------------|
| `ayu-night` | `dark` | `#10141c` | `#bfbdb6` |
| `ayu-dusk` | `mirage` | `#242936` | `#cccac2` |
| `ayu-day` | `light` | `#fcfcfc` | `#5c6166` |

The colours are the _original_ Ayu ones, not an approximation: every
hex value either comes from the palette files of
[ayu-theme/ayu-colors](https://github.com/ayu-theme/ayu-colors)
(`themes/dark.yaml`, `themes/mirage.yaml`, `themes/light.yaml`),
resolved with the official generator, or is derived from them by
`scripts/gen-palette.py` (the composited alpha colours and the
`*-strong` family -- see [Provenance of the colours](#provenance-of-the-colours)). Syntax
highlighting follows the scope mapping that ships with that repository
(`designer/lib/shiki-theme.ts`, the one https://ayutheme.com/ renders
its previews with), translated to Emacs faces; the same section lists
the handful of places where that translation has to be coarse.

About 2200 faces are defined per flavour, covering the Emacs core UI,
font lock and tree-sitter, org, the completion frameworks, version
control, the tree sidebars, the mode line families, terminals, mail
and news, and the long tail of small packages. See the [Coverage](#coverage)
section for the list.

## Demo

The three flavours in a real Emacs (the configuration of the machine, brought up
through `emacsclient`), walking through six generated files: go, php, js, html,
python and shell. The snippets are made up (an HTTP middleware that gives every
request "the lease of a summer"), but the colours are not: the tape paints
nothing itself, so every pixel of the frame is one Emacs drew from the palette.
The cursor is walked over the lines, which is what lights up the current line
number.

![dusk](https://i.imgur.com/99zjKco.gif)
![night](https://i.imgur.com/fgtrmFk.gif)
![day](https://i.imgur.com/8UA4EIY.gif)

## Installation

### From GitHub with `straight.el`

```elisp
  (use-package ayu-themes
    :straight (:type git :host github :repo "1buran/ayu-emacs-theme"
                     :files ("ayu-themes.el" "ayu-*-theme.el")))
```

### From a local checkout

The `ayu-*-theme.el` files load `ayu-themes.el` from their own directory, so it
is enough for Emacs to find the `*-theme.el` files:

```elisp
  (add-to-list 'load-path "/path/to/ayu-emacs-theme")
  (add-to-list 'custom-theme-load-path "/path/to/ayu-emacs-theme")
```

Emacs 29.1 or newer is required (the themes use the `font-lock-operator-face`,
`font-lock-number-face` and friends that Emacs 29 added for tree-sitter).

## Usage

```elisp
(load-theme 'ayu-night t) ; or 'ayu-dusk, 'ayu-day
```

Three commands make flavour switching easy:

- `M-x ayu-themes-load RET dusk RET` -- load a flavour and disable the other
  Ayu themes. Other themes are left alone.
- `M-x ayu-themes-cycle` -- go night -> dusk -> day -> night. Handy on a key:
  ```elisp
  (keymap-global-set "C-c y" #'ayu-themes-cycle)
  ```
- `M-x ayu-themes-refresh` -- rebuild the enabled theme. The face specs of a
  theme are computed when the theme is defined, so run this after changing one
  of the options below (the `ayu-themes-toggle-*` commands do it for you).

## Options

Every option defaults to the original Ayu look; the ones that change the
palette are opt-in.

| Option | Default | Effect |
|-------------------------------------|---------|------------------------------------------------------------------------------|
| `ayu-themes-italic-comments` | `t` | Slanted comments, doc strings and block quotes -- as Ayu itself does it. |
| `ayu-themes-contrasted-comments` | `nil` | Use a brighter (dark flavours) or darker (day) comment colour. |
| `ayu-themes-contrasted-syntax` | `nil` | Use the more contrasted variant of every syntax colour. |
| `ayu-themes-contrasted-foreground` | `nil` | Use a stronger `default` foreground. |
| `ayu-themes-scale-org-headlines` | `nil` | `t` for the default heights (1.3 / 1.15 / 1.05) on `org-level-1..3`, or a number. |
| `ayu-themes-org-intense-colors` | `nil` | Add an overline and a tinted background to the org headlines. |
| `ayu-themes-mode-line-border` | `nil` | Draw a box around the mode line. |

Each one has a matching `M-x ayu-themes-toggle-...` command:

```elisp
(ayu-themes-toggle-italic-comments)
(ayu-themes-toggle-contrasted-comments)
(ayu-themes-toggle-contrasted-syntax)
(ayu-themes-toggle-contrasted-foreground)
(ayu-themes-toggle-org-headline-scaling)
(ayu-themes-toggle-org-intense-colors)
(ayu-themes-toggle-mode-line-border)
```

## Contrast

WCAG contrast ratios of the syntax colours against the flavour background, as
shipped. The dark flavours are comfortable; Ayu's `day` palette is _soft by
design_ (its syntax colours sit around 2:1, which is what the official theme
looks like), so `ayu-themes-contrasted-syntax` exists for people who find it
too faint. Comments are deliberately quiet in all three flavours.

| Colour | night | dusk | day | day, contrasted |
|---------------|-------|------|------|-----------------|
| default fg | 9.8 | 8.9 | 6.1 | 9.5 |
| accent | 9.7 | 9.7 | 2.2 | 4.3 |
| tag | 8.2 | 8.0 | 2.3 | 3.4 |
| func | 10.5 | 9.8 | 2.1 | 3.5 |
| entity | 9.3 | 8.4 | 2.7 | 3.4 |
| string | 11.2 | 12.8 | 2.4 | 3.3 |
| regexp | 12.7 | 10.0 | 2.2 | 3.3 |
| markup | 6.4 | 5.9 | 2.8 | 3.8 |
| keyword | 8.1 | 7.5 | 2.4 | 3.7 |
| special | 10.8 | 8.1 | 2.3 | 3.6 |
| constant | 9.3 | 9.0 | 3.3 | 3.7 |
| operator | 8.2 | 6.9 | 2.0 | 3.8 |
| comment | 3.1 | 3.4 | 2.2 | 3.5 |

## Provenance of the colours

The reference is what https://ayutheme.com/ renders. It can be read in three
steps, every one of them a file you can fetch and check, and none of the values
in this package is eyeballed or invented. This section is here so that the next
person does not have to search for it again.

### The palette

The official data lives in [ayu-theme/ayu-colors](https://github.com/ayu-theme/ayu-colors):

| Flavour | File |
|-------------|----------------------|
| `ayu-night` | `themes/dark.yaml` |
| `ayu-dusk` | `themes/mirage.yaml` |
| `ayu-day` | `themes/light.yaml` |

The YAML is not a list of hex values. It stores colours in OKLCH with relative
chroma and modifiers, and names the ramp instead:

```yml
syntax:
tag: $palette.indigo.l2
func: $palette.yellow.l4 # function names
entity: $palette.blue.l3
string: $palette.green.l4
regexp: $palette.teal.l5
markup: $palette.red.l2
keyword: $palette.orange.l3
special: $palette.peach.l4
comment: $palette.gray.l4
constant: $palette.purple.l3 # constants
operator: $palette.pink.l3
```

So "constants are violet" and "function names are orange" are not decisions made
in this package: `constant: purple` and `func: yellow` are written in that file.
Resolve it with the repository's own generator (`src/` and `scripts/`); the
values cannot be read as hex by hand, because they are OKLCH and the ramp steps
are applied on top. The resolved output is what the palettes here copy -- and
`scripts/gen-palette.py` of this package turns it into them, see
[When Ayu changes](#when-ayu-changes).

The resolved output is what the palettes here copy, and it is published as well:
the npm package _ayu_ (v9.1.0 at the time of writing), in the
`dist/generated/dark.js`, `mirage.js` and `light.js` files, each headed
"Auto-generated from themes/dark.yaml". Note the entry points -- `dist/dark.js`
is a 404, only `dist/generated/dark.js` exists:

```sh
curl -s https://raw.githubusercontent.com/ayu-theme/ayu-colors/master/themes/dark.yaml
curl -s https://cdn.jsdelivr.net/npm/ayu@9.1.0/dist/generated/dark.js
```

The site itself carries the resolved colours in its CSS, which makes it a
one-command cross-check of what the palette means:

```sh
curl -s https://ayutheme.com/ | tr ';' '\n' | grep -- '--syntax-'
```

That prints `--syntax-func: #ffb454` and `--syntax-constant: #d2a6ff` for the
dark flavour, and the corresponding pairs for mirage and light.

### The scope map

Which TextMate scope gets which semantic token is the table that ships with
that same repository, in `designer/lib/shiki-theme.ts` -- the mapping
https://ayutheme.com/ renders its previews with:

```sh
curl -s https://raw.githubusercontent.com/ayu-theme/ayu-colors/master/designer/lib/shiki-theme.ts
```

| Scope in `shiki-theme.ts` | Token | Emacs face |
|------------------------------------------------|-------------|-----------------------------------|
| `comment` | `comment` | `font-lock-comment-*` (+ italic) |
| `string`, `entity.name.import` | `string` | `font-lock-string-face` |
| `string.regexp`, `constant.character` | `regexp` | `font-lock-regexp-face`, `escape` |
| `constant.numeric`, `constant.language` | `constant` | `font-lock-constant-face` |
| `variable` | `editor.fg` | `font-lock-variable-name-face` |
| `variable.member` | `markup` | `font-lock-property-*-face` |
| `variable.language` (this/self/super) | `tag` | `font-lock-builtin-face` |
| `storage`, `keyword` | `keyword` | `font-lock-keyword-face` |
| `keyword.operator`, `punctuation.accessor` | `operator` | `font-lock-operator-face` |
| `entity.name.function`, `variable.function` | `func` | `font-lock-function-name-face` |
| `variable.parameter`, `meta.parameter` | `constant` | none of its own (see below) |
| `support.function`, `support.macro` | `markup` | `font-lock-builtin-face` |
| `entity.name`, `support.type`, `support.class` | `entity` | `font-lock-type-face` |
| `entity.name.tag`, `meta.tag.sgml` | `tag` | the html/XML tag faces |
| `entity.other.attribute-name` | `func` | the attribute faces |
| `punctuation.separator` (70% alpha) | `editor.fg` | `font-lock-delimiter-face` |
| `punctuation.*`, `meta.brace` | `editor.fg` | `font-lock-punctuation-face` |
| `invalid` | `#d95757` | `font-lock-warning-face` |

The top of `ayu-themes.el` carries a shorter version of this table; this one is
the full one.

### Where the translation is coarse

Emacs has fewer faces than TextMate has scopes, so three mappings cannot be
exact. They are approximations _inside_ the official palette, not deviations
from it -- the colours themselves are Ayu's:

- `font-lock-builtin-face` is a single face for two scopes Ayu colours
  differently: `support.function` and `support.macro` (`markup`, the red one),
  and `variable.language` (`tag`, cyan, italic). The theme gives it
  `syntax-markup`, so `this`, `self` and `super` come out red where Ayu renders
  them cyan, and the italic is lost.
- `variable.parameter` is `constant` (violet) in Ayu, but Emacs has no parameter
  face -- `font-lock-parameter-face` does not exist, checked in 31.1 -- and
  parameters are declared through `font-lock-variable-name-face`, which Ayu
  renders as plain foreground. Function arguments therefore stay uncoloured.
- `support.constant` is `operator` with italic in Ayu. Emacs has no face of its
  own for it either, so whatever face the mode picks decides the colour.

Two more things worth knowing:

- The alpha scopes are composited, because an Emacs face takes opaque colours
  only. The separators of Ayu (`punctuation.separator`, 70% of the foreground,
  carried by the site as `--editor-fg-70a: #bfbdb6b3`) arrive as `fg-delim`,
  which _is_ that composite: `#bfbdb6` over `#10141c` gives `#8a8a88`, the value
  in the palette. The tag punctuation (50%, `--syntax-tag-50a`) is
  approximated the same way.
- The `*-strong` family is _not_ from the official map. It exists for the
  opt-in `ayu-themes-contrasted-syntax`, and every value is a real colour of the
  same palette -- the far end of the ramp of that hue. `syntax-constant` is
  `#d2a6ff` (`purple-3`) and `syntax-constant-strong` is `#e3c9ff` (`purple-5`);
  the `day` palette runs the other way, so there it is the darkest step. With
  the option off, only the official values are used. Three entries that look
  like this family are not ramp ends but blends of two official colours --
  `comment-strong`, `fg-strong` and `border-strong` -- and the next subsection
  says what they are.

### When Ayu changes

The palettes are not hand-written, so an update is a re-run rather than a
re-invention. `scripts/gen-palette.py` reads the resolver output and prints the
value of `ayu-themes-palettes` -- the same wrapping and blank lines as in the
file, so the change is a paste and the diff shows only the colours that moved:

```sh
curl -sO https://cdn.jsdelivr.net/npm/ayu@9.1.0/dist/generated/dark.js
curl -sO https://cdn.jsdelivr.net/npm/ayu@9.1.0/dist/generated/mirage.js
curl -sO https://cdn.jsdelivr.net/npm/ayu@9.1.0/dist/generated/light.js
scripts/gen-palette.py --night dark.js --dusk mirage.js --day light.js
```

The same run prints the WCAG report the [Contrast](#contrast) table above is built from.
Which entries are Ayu's and which are computed here is spelled out in the
docstring of the script; in short:

- everything the resolver publishes is taken as it is: the `syntax.*` tokens and
  the eleven hue ramps, the terminal colours, `vcs.*`, `surface.*`, `editor.*`,
  `ui.*` and `common.*`;
- the selection, findMatch, line and panel entries arrive with the alpha already
  in their 8 digit hex (`3388ff40`), so they are composited over the flavour
  background: an Emacs face takes opaque colours only;
- the alphas Ayu does not supply are the constants of `build()`: _10%_ for
  `bg-alt`, _18%_ and _38%_ for the diff backgrounds, _35%_ for the error and
  warning ones, _30%_ for `border-strong`, _50%_ and _80%_ for `fg-ghost` and
  `fg-faint`, _70%_ for `fg-delim`, _55%_ for `accent-dim`;
- `comment-strong` is the foreground mixed halfway into the comment colour, and
  `fg-strong` moves the foreground 60% toward white (night, dusk) or black
  (day);
- `warning` and `bg-warning` use `palette.yellow.l4`, because Ayu has no warning
  token of its own;
- `bg-sunk` of the night flavour is the one deliberate deviation.

The `*-strong` family exists because the `day` palette is low-contrast by
design: its syntax colours sit at 2.0-3.3:1, which is what the official light
theme looks like and what the classic ayu-light Sublime scheme uses. The
authentic values stay the default and the option is there for eyes that cannot
read them; `night` and `dusk` need no help (comments 3.15 and 3.42, syntax
5.9-12.8).

Then:

1. paste the block into `ayu-themes-palettes`;
2. update the [Contrast](#contrast) table from the report;
3. add a CHANGELOG entry -- a change of colours is a minor release;
4. run the checks of [Development](#development): the ert tests, the warning-free byte
   compile and a load of all three flavours. Finish by reading one value off a
   real frame; batch Emacs does not render, so a wrong colour looks perfect
   there.

## Coverage

`ayu-themes.el` groups the faces into thirteen sections, one function each:
`base`, `font-lock`, `lang`, `org`, `text`, `completion`, `diagnostics`, `vc`,
`files`, `modeline`, `term`, `misc` and `extra`. Roughly, in package terms:

- _Core UI_ -- `default`, `cursor`, `region`, `hl-line`, `fringe`, `line-number`,
  fill column, whitespace, isearch, show-paren, next-error, compilation, the
  widget/customize set, `completions-*`, tooltips, scroll bars, window dividers.
- _Font lock_ -- the complete `font-lock-*` set (including the Emacs 29
  additions: operator, number, property, punctuation, bracket, delimiter,
  escape, doc-markup, function-call, misc-punctuation) plus the old
  `tree-sitter-hl-face:*` names. Tree-sitter fontification in Emacs 29+ goes
  through `font-lock-*`, so it is covered by the same specs.
- _Languages_ -- sh, makefile, cperl, js2, typescript, rjsx, css/scss/sass,
  clojure, haskell, verilog, elisp, agda, ledger, pkgbuild, rpm-spec.
- _Org_ -- org headlines, todos, tags, dates, code/verbatim, tables, blocks,
  quotes, agenda, habits, `org-ref`, `org-pomodoro`, `org-modern`, outline and
  `outline-minor-faces`.
- _Text_ -- markdown, reStructuredText, AUCTeX/font-latex/reftex, nxml/sgml,
  web-mode, Info/man/woman, shr/eww.
- _Completion_ -- company (+ `company-box`), corfu, vertico, selectrum, ivy,
  counsel, swiper, helm, orderless, marginalia, embark, which-key, eldoc,
  icomplete, ctrlf, helpful.
- _Diagnostics_ -- flycheck (+ posframe), flymake, flyspell, jinx, spell-fu,
  lsp-mode (+ lsp-ui), eglot, dap-mode.
- _Version control_ -- diff, smerge, ediff, diff-hl, git-gutter (+ fringe),
  magit, forge, git-commit, git-rebase, log-view/log-edit, vc-dir.
- _Files_ -- dired, diredfl, dired+, dired-k, dired-async, dired-subtree,
  treemacs, neotree, all-the-icons, nerd-icons, ibuffer, proced, speedbar,
  image-dired.
- _Mode line_ -- the stock mode/header line, tab-bar, tab-line, tabbar,
  centaur-tabs, elscreen, powerline, spaceline, smart-mode-line,
  telephone-line, doom-modeline, mood-line, nano-modeline, keycast,
  perspective/persp-mode/workgroups2, solaire-mode.
- _Terminals_ -- ansi-color, term, vterm, eat, comint, eshell.
- _Misc_ -- rainbow-delimiters, hl-todo, highlight-numbers/quoted/symbol/thing,
  hi-lock, indent guides, minimap, wgrep, iedit, yasnippet, undo-tree, avy,
  ace-window/jump, anzu, bm, volatile-highlights, vimish-fold, goggles,
  annotate, stripe-buffer, symbol-overlay, nav-flash, beacon, crosshairs,
  calendar/diary/calfw, elfeed, erc/circe/rcirc, message/gnus/notmuch/mu4e,
  alert, tabulated-list, csv, change-log, apropos.
- _Long tail_ -- transient, projectile, rg/ripgrep, php-mode, go-mode,
  terraform/dockerfile/hcl, js2/rjsx, salt-mode, geben, dap-mode, web-mode
  leftovers, markdown and AUCTeX leftovers, worklog, gptel, hydra, popup,
  dired-hacks, mmm-mode, origami, flycheck and lsp-mode leftovers (including
  the semantic-token faces lsp-mode generates per client).

If something is missing, add it to the matching `ayu-themes--faces-...`
function; it is picked up automatically.

### Tree-sitter modes

A tree-sitter buffer is the best lit one, because the theme styles every face
those modes use. The classic modes are thinner, and one case is worth knowing
about: `yaml-mode` hands a key to `font-lock-variable-name-face`, and the
official Ayu renders the `variable` scope as plain foreground, so keys and bare
scalars stay uncoloured there. Ayu's own previews look different only because
their TextMate grammar calls a key `entity.name.tag`. With `yaml-ts-mode` the
keys, the plain scalars and numbers, the delimiters and the comments all get a
colour. Measured on Emacs 31.1, the tree-sitter modes hand font-lock this many
faces and the theme styles every one of them: go 10, php 11, js 10, html 5,
css 10.

#### The grammar recipe lives in the mode, not in Emacs

Emacs does not ship the grammars -- they are compiled C libraries, not Elisp --
but every tree-sitter mode registers its own recipe, _including the revision
Emacs was tested against_, as soon as the library that defines the mode is
loaded:

```elisp
(progn (require 'go-ts-mode) (assq 'go treesit-language-source-alist))
;; => (go "https://github.com/tree-sitter/tree-sitter-go"
;; :commit "12fe553fdaaa7449f764bc876fd777704d4fb752")
```

`M-x treesit-install-language-grammar` and the "grammar is missing, install
it?" prompt that the modes ask themselves both work off those entries, so a
missing grammar is one command away and the revision is never guessed:

```elisp
(require 'go-ts-mode) ; registers the recipe
(treesit-install-language-grammar 'go) ; builds it into ~/.emacs.d/tree-sitter/
```

Do not hand-write the alist. It looks tempting, and it is how this README used
to do it, but an entry without `:commit` installs the default branch, which may
be newer than the revision the mode's queries were written for. Two more
details: a few modes share a library (`css-ts-mode` lives in `css-mode.el`,
`js-ts-mode` in `js.el`), and a mode may want more than one grammar
(`php-ts-mode` needs `php`, `phpdoc` and `jsdoc`; `go-ts-mode` needs `go`,
`gomod` and `gowork`).

Where Emacs has no tree-sitter mode there is no recipe to trust: SCSS and Sass
have none in 31.1, so `scss-mode` and `sass-mode` stay as they are. For those
languages the recipe lists of nvim-treesitter, helix or `treesit-auto` are a
community convention, not a reference.

#### A tree-sitter mode does not inherit the classic mode's hooks

A tree-sitter mode is declared as derived from the mode it replaces, but that
declaration is only for `derived-mode-p`: neither the hooks nor the keymaps are
inherited, and on a remapped path the classic mode is not loaded at all. A
check that takes one line:

```elisp
;; in a go-ts-mode buffer, go-mode-hook does not run by itself
(add-hook 'go-mode-hook (lambda () (setq ran t)))
(with-temp-buffer (go-ts-mode) ran) ; => nil
```

So every hook attached to `go-mode-hook` (`lsp`, `yasnippet`, `indent-bars`,
`add-node-modules-path`) would silently stay off, and the helpers that are not
autoloaded (`gofmt-before-save`, `go-remove-unused-imports`,
`go-goto-imports`) would be void. Run the classic hooks and adopt the classic
keymap from the tree-sitter mode's own hook:

```elisp
(defun my-ts-adopt-classic-mode ()
"Run the classic modes' hooks and inherit their keymaps."
(dolist (classic (cdr (assq major-mode '((go-ts-mode . (go-mode))
(php-ts-mode . (php-mode))))))
(require classic nil t)
(run-hooks (intern (concat (symbol-name classic) "-hook")))
(let ((classic-map (intern (concat (symbol-name classic) "-map")))
(mode-map (intern (concat (symbol-name major-mode) "-map"))))
(when (and (boundp classic-map) (boundp mode-map))
(set-keymap-parent (symbol-value mode-map) (symbol-value classic-map))))))

(add-hook 'go-ts-mode-hook #'my-ts-adopt-classic-mode)
(add-hook 'php-ts-mode-hook #'my-ts-adopt-classic-mode)
```

`html-ts-mode` is the exception: it really is derived from `html-mode`, so that
hook runs by itself. For JavaScript the classic setup is spread over
`js-mode-hook`, `js2-mode-hook` and `rjsx-mode-hook`, and all three have to be
run.

#### Emacs highlights three of the four levels

`treesit-font-lock-level` is 3 by default, and a number of features sit in the
fourth, where they simply do not paint. The one that shows in a Go buffer: a
method call on an object, `x.Foo()`, is given `font-lock-function-call-face`
only at level 4, so `logger.Debug` and `r.PublishNews` stay uncoloured where
go-mode painted them yellow. The `:` and `-` delimiters of YAML are in the same
level. The fourth level also paints the `ERROR` nodes of a parse with
`font-lock-warning-face`, so a file the grammar cannot digest shows it instead
of staying silent.

```elisp
(setq treesit-font-lock-level 4)
```

Measured on a 2000 line Go file, that level costs: the first fontification goes
from 34 to 64 ms, an edit from 0.36 to 0.40 ms. Buffers that are already open
do not notice the change -- run `M-x treesit-font-lock-recompute-features` and
`M-x font-lock-flush` in them, or reopen the file.

#### Tree-sitter is more precise, not cheaper

On a 20000 line YAML file (458 KB) the classic regexp mode needed 1.6 ms per
edit against 3.0 ms for `yaml-ts-mode`, and 3.8 MB of memory against 27 MB; on
the sizes a config file has (a few KB) neither number is noticeable. Do not
switch for speed -- switch for the colours, and pick your modes per language:
`js2-mode`, for instance, has more faces of its own than `js-ts-mode`.

#### Checking what a mode really highlights

For a theme the faces are the whole point, and a grammar that does not match the
queries of its mode makes part of the fontification silently disappear. The way
to tell is to list the faces the mode actually applies; this needs no display,
so it works in `--batch`:

```elisp
(with-temp-buffer
(insert-file-contents "sample.go")
(go-ts-mode)
(font-lock-ensure)
(let (faces)
(goto-char (point-min))
(while (not (eobp))
(let ((face (get-text-property (point) 'face)))
(push (if (listp face) (car face) face) faces))
(forward-char 1))
(sort (delete-dups (delq nil faces)) #'string<)))
```

A face in that list that the theme does not style is a gap in the theme; a face
that is missing from the list is a feature the grammar does not provide.

### Checking the coverage

A face that a package defines but the theme does not style silently falls back
to the default foreground. To find those, collect the faces of the packages
you have installed and subtract the ones the theme sets:

```elisp
(let ((ayu-themes--palette (alist-get 'night ayu-themes-palettes)))
(length (ayu-themes--face-specs))) ; => 2196 faces
```

On a machine with ~900 third-party faces installed this leaves 45 unstyled
faces, and all of them belong to other themes (`doom-themes`, `modus-themes`,
`timu-spacegrey-theme`) or to the niche UI libraries `bui.el` and `llama`.

## Architecture

`ayu-themes.el` holds the whole thing and the three `ayu-*-theme.el` files are
~45 lines each: they only require the core and call

```elisp
(ayu-themes-define-theme ayu-night night "Ayu night: ...")
```

The face list exists once. Each entry is written against the palette being
defined with the internal `ayu` macro and the option-aware helpers
(`ayu-themes--syntax`, `ayu-themes--comment`, `ayu-themes--foreground`,
`ayu-themes--scale`, `ayu-themes--intense`, `ayu-themes--mode-line-border`), so
adding a flavour means adding ~115 colour entries -- the same shape of design
that `modus-themes' and `ef-themes' use, in a much smaller package.

The palettes themselves (`ayu-themes-palettes`) are plain alists of semantic
names, the whole official ramp of every hue (`"orange-1"` .. `"orange-5"`, from
darkest to lightest) and the 16 terminal colours. They are a convenient way to
grab a colour for your own faces:

```elisp
(require 'ayu-themes)
(cdr (assq 'orange-3 (alist-get 'night ayu-themes-palettes))) ; => "#ff8f40"
```

Notes on the translation:

- Ayu's alpha colours (selections, indent guides, ...) are composited over the
  background they are meant to be drawn on, because Emacs faces take opaque
  colours only.
- `surface.sunk` of the dark flavour is a near-black (`#010102`) in the official
  palette; the theme uses the classic ayu-dark background (`#0a0e14`) for that
  slot instead, so that fringes and gutters do not turn into a black hole.
- Every face uses the display spec `((class color) (min-colors 89))`, so on a
  terminal without colour support the faces are simply left alone instead of
  being approximated into mud.

## Development

Everything byte-compiles without warnings:

```elisp
emacs -Q -L . -f batch-byte-compile ayu-themes.el ayu-\*-theme.el ayu-themes-check.el
```

`ayu-themes-check.el` holds the invariants as ERT tests -- palette entries are
plain hex strings, all flavours define the same faces, no face carries a
malformed attribute value, and the options do not break any of that:

```elisp
emacs -Q --batch -L . -l ayu-themes-check.el -f ert-run-tests-batch-and-exit
```

They exist because Emacs is quiet about the mistakes this table can make: a
colour that arrives as a list instead of a string, or a `(list ...)' left inside
a backquoted spec, produces a face that is never rendered and no error at all.
Loading a theme still checks one more thing -- that every palette entry a face
asks for exists, since the `ayu` macro signals an error naming a missing one:

```elisp
emacs -Q --batch -L . --eval '(progn
(add-to-list (quote custom-theme-load-path) default-directory)
(load-theme (quote ayu-night) t))'
```

To pick a change up in a running Emacs, load the core and then the theme; the
core has to be reloaded explicitly, because the face specs are macro expanded
when the file is loaded and `require` would be a no-op:

```elisp
(load "/path/to/ayu-themes.el")
(load-theme 'ayu-night t)
```

## Demos

The recordings at the top of this file are made by
[vhs](https://github.com/charmbracelet/vhs) from `demo/vhs.tape`: one tape for
all three flavours. The tape brings Emacs up with `emacsclient -c`, so the
recording is made in the configuration that is already running on the machine,
and walks the six generated snippets of `demo/snippets/` -- go, php, js, html,
python and shell -- with `C-n`, moving the cursor over the lines so that the
current line number lights up. It writes the GIF and a still screenshot into
`demo/output/`.

Which flavour a run shows comes from `demo/output/active.mode`: `demo/init.el`
reads it, enables that Ayu flavour and stores the flavour that was enabled
before it in `demo/output/prev.mode`, so a caller can put the original theme
back when the run is over. Nothing else is set up by the tape -- no `Set Theme`,
no margin, only the few pixels of padding that frame the terminal -- and the
`record demo` task starts vhs with `TERM=xterm-direct`, so the frame is painted
with the palette values themselves rather than with a 256 colour approximation
of them.

The snippets are opened read-only, with line and column numbers, and the
configuration around them is the real one: the frame shows the language modes,
the mode line and the paths the theme is used with every day. A configuration
also writes into the echo area, the line under the mode line, and a message stays
there until the next one arrives -- `lsp-mode`, for one, announces every server
it starts together with the folders of the projects that happen to be open next
to the snippets, and a key that cannot edit a read-only snippet leaves its error
behind. `demo/init.el` silences that line for as long as the recorded frame
lives, through the two hooks a message of the frame goes through:
`set-message-function` (returning `t` means the message is handled and not
displayed, and it is still logged to `*Messages*`) and `command-error-function`.
The one message that no hook of the file can catch is its own "Loading ..."
banner, which Emacs prints before the file is read, so the tape binds
`inhibit-message` around the `load`. Everything is put back when the recorded
frame is closed. What has to be prevented rather than silenced is a question,
because a prompt is read and not written: `lsp-mode` asks one before it starts
watching the files of a repository with many directories
(`lsp-enable-file-watchers`), and the harness answers it in advance.

Look at `demo/output/` before publishing anything, and upload only when the
recordings have been agreed on: an Imgur upload cannot be taken back. Recording
and publishing are the two [xc](https://xcfile.dev/) tasks at the end of this
file; the upload needs an Imgur client id, which lives in a gitignored `.env`.
Note that a client id authorises the application, not an account: images
uploaded with it are anonymous and do not appear in the Imgur profile. Upload
them with an OAuth access token (`Authorization: Bearer ...`) if they are to
belong to an account.

## Tasks

These are tasks of [xc](https://github.com/joerdav/xc) runner.

### record demo

Record demo of three theme modes.

```
for i in day dusk night; do
    echo $i > demo/output/active.mode
    env TERM=xterm-direct \
    AYU_DEMO_SNIPPETS=demo/snippets \
    vhs demo/vhs.tape && \
    mv demo/output/output.gif demo/output/$i.gif && \
    mv demo/output/screenshot.png demo/output/$i.png
    prev=$(<demo/output/prev.mode)
    emacsclient -e "(ayu-themes-load '$prev)"
done
```

### publish recordings

Upload to Imgur and update readme.

```
declare -A demo=()
demo["day.gif"]="day"
demo["dusk.gif"]="dusk"
demo["night.gif"]="night"

for i in ${!demo[@]}; do
    . .env && url=`curl --location https://api.imgur.com/3/image \
        --header "Authorization: Client-ID ${clientId}" \
        --form image=@demo/output/$i \
        --form type=image \
        --form title=ayu-emacs-$i-theme \
        --form description=Demo | jq -r '.data.link'`
    sed -i "s#^\!\[${demo[$i]}\].*#![${demo[$i]}]($url)#" README.md
done
```

## License

MIT, see [LICENSE](LICENSE). The Ayu palette and the scope mapping are
copyright of their authors ([ayu-theme/ayu-colors](https://github.com/ayu-theme/ayu-colors), MIT).
