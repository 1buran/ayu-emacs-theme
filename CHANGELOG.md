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
