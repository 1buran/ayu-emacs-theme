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
- `README.org`: installation, usage, the options, a WCAG contrast table for all
  three flavours, the coverage list and a note on the architecture.
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

### Fixed

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
