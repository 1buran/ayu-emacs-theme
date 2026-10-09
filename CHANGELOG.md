# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
The first release will be `v1.0.0`, which is the version the `Version:` headers
of `ayu-themes.el` and of the three `ayu-*-theme.el` files carry.

## [Unreleased]

### Added

- The three Ayu flavours as Emacs themes: `ayu-night` (official `dark`),
  `ayu-dusk` (official `mirage`) and `ayu-day` (official `light`), with the
  original palette values taken from `ayu-theme/ayu-colors` and the syntax
  mapping from the TextMate scope table that ships with it.
- 2196 faces per flavour, grouped into thirteen sections: core UI, font lock
  (including the Emacs 29 additions that tree-sitter uses), language modes,
  org, markup, completion, diagnostics, version control, files and trees, mode
  lines, terminals, misc and the long tail of small packages.
- The `ayu-themes--faces-extra` section, which closes the coverage gaps found by
  auditing the faces of the packages installed on a working machine: lsp-mode,
  web-mode, doom-modeline, php-mode, magit, nerd-icons, transient, diff-hl,
  go-mode, flycheck, projectile, rg, treemacs, dap-mode and others. Of the 898
  third-party faces installed there, 45 are left unstyled, and all of them
  belong to other themes or to niche UI libraries.
- Options, all defaulting to the original Ayu look:
  `ayu-themes-italic-comments` (`t`, as Ayu itself renders comments),
  `ayu-themes-contrasted-syntax`, `ayu-themes-contrasted-comments`,
  `ayu-themes-contrasted-foreground`, `ayu-themes-scale-org-headlines`,
  `ayu-themes-org-intense-colors` and `ayu-themes-mode-line-border`, with a
  `ayu-themes-toggle-*` command each.
- The commands `ayu-themes-load`, `ayu-themes-cycle` and `ayu-themes-refresh`.
- `README.md`: installation (including a full `use-package` + `straight.el`
  setup), usage, the options, a WCAG contrast table for all three flavours, the
  coverage list and a note on the architecture.
- `AGENTS.md`: the contributor guide, including the provenance of the colours,
  the verification commands and the research notes that explain why the package
  is laid out the way it is.
- `ayu-themes-check.el`: the invariant checks as ert tests -- palette entries are
  plain hex strings, every flavour defines the same faces, no spec carries a
  malformed attribute value, and the options do not break any of that.
- A README section on the tree-sitter modes: why a tree-sitter buffer is the
  best lit one (the `yaml-mode` keys are flat because Ayu renders the `variable`
  scope as plain foreground), where Emacs keeps the grammar recipes -- each mode
  registers its own, with the revision Emacs was tested against -- how to
  install a grammar from that recipe instead of hand-writing the alist, the fact
  that a tree-sitter mode does not inherit the classic mode's hooks or keymaps
  and what to do about it, and how to list the faces a mode actually applies.
- Two more findings in that section: `treesit-font-lock-level` is 3 by default
  and several features -- a Go method call, the YAML delimiters, the ERROR nodes
  of a parse -- live in the fourth level, where they do not paint at all; and
  tree-sitter is more precise but not cheaper, with the numbers to prove it
  (1.6 ms against 3.0 ms per edit on a 458 KB YAML, 3.8 MB against 27 MB).
- A README section on the provenance of the colours, so the sources do not have
  to be searched for a second time: the palette files of `ayu-theme/ayu-colors`
  (OKLCH, with `constant: purple` and `func: yellow` written in the file), the
  resolved output of its generator as published in the npm package, the scope
  table of `designer/lib/shiki-theme.ts`, each with the command that fetches it
  and a cross-check against the CSS of <https://ayutheme.com/>. It also records
  the full scope -> token -> face table, the three mappings Emacs cannot express
  exactly (`variable.language` sharing `font-lock-builtin-face` with
  `support.function`, and `variable.parameter` / `support.constant` having no
  face of their own), how the alpha scopes are composited, and that the
  `*-strong` family is local to `ayu-themes-contrasted-syntax` and is the far end
  of the same hue ramp.
- A `When Ayu changes` subsection of that section: the recipe for a palette
  update (fetch the three resolver files, run the generator, diff the block,
  refresh the contrast table, run the checks) and the list of the values that
  are not Ayu's, with the reason the `*-strong` family exists at all -- the
  `day` palette sits at 2.0-3.3:1 by design, which is what the official light
  theme looks like.
- `scripts/gen-palette.py`: the generator that produced the palettes, rescued
  from a temporary directory. It reads the published resolver output and prints
  the body of `ayu-themes-palettes` ready to paste -- same wrapping, so a
  re-run is a paste -- plus the WCAG report the contrast table is built from.
  It is the only record of the derived values: the alphas that Ayu does not
  supply (10% to 80%, `bg-alt`, the diff, error and warning backgrounds, the
  weaker foregrounds), `comment-strong`, `fg-strong`, the `*-strong` ramp ends,
  `warning` from `palette.yellow.l4`, and the `bg-sunk` deviation. `.gitignore`
  now covers `__pycache__/` for it.
- `demo/`: the recordings behind the `Demo` section of the README. One
  [vhs](https://github.com/charmbracelet/vhs) tape (`demo/vhs.tape`) runs all
  three flavours through the six generated snippets -- go, php, js, html, python
  and shell -- and writes both the GIF and a still screenshot into
  `demo/output/`. The tape starts Emacs through `emacsclient -c`, so the
  recordings show the theme inside a real configuration: `demo/init.el` picks the
  flavour up from `demo/output/active.mode`, walks the snippets with `C-n`, and
  silences the echo area -- the line under the mode line, where a configuration's
  messages would otherwise stay -- for as long as the recorded frame lives. Added
  [xc](https://xcfile.dev/) tasks for recording the screen and for publishing the
  recordings to Imgur and rewriting the links in the README.

### Fixed

- `README.md` and `AGENTS.md` claimed that every palette value comes from the
  Ayu palette files. 19 entries per flavour do not: they are the composited
  alpha colours and the `*-strong` family, computed by
  `scripts/gen-palette.py`. Both documents say so now, and the provenance
  section names the three entries that look like ramp ends but are blends of
  two official colours: `comment-strong`, `fg-strong` and `border-strong`.
- The themes were built but nothing was coloured on screen: the `ayu` macro
  resolved a palette entry with `cdr` instead of `cadr`, so every colour reached
  the faces as a one element list (`("#10141c")`). Emacs accepted the specs and
  silently ignored them — `M-x load-theme` reported no error at all. Colours now
  arrive as strings; batch checks could not see this, `ayu-themes-check.el` can.
- `tab-bar-tab` got an unevaluated `(list :line-width 1 :color ...)` as its
  `:box` value, because a bare `list` call inside the backquoted face spec is
  data, not a call. That one did fail loudly (`Invalid face box: list, ...`).
  The value is now built by `ayu-themes--box`, which also serves the mode line
  border.
