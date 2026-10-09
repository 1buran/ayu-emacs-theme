#!/usr/bin/env python3
"""Generate the palette alists of ayu-themes.el from the official ayu-colors output.

The palettes in ayu-themes.el are not hand-written: they are the official Ayu
colours plus a small number of values derived here.  This script is the record of
that derivation, so a palette update is a re-run rather than a re-invention.

Input
-----

The resolved output of the official generator, published in the npm package
`ayu' (v9.1.0 at the time of writing) as `dist/generated/{dark,mirage,light}.js'.
Fetch the three files and note the paths: `dist/dark.js' is a 404, only the
`generated/' one exists.

    curl -sO https://cdn.jsdelivr.net/npm/ayu@9.1.0/dist/generated/dark.js
    curl -sO https://cdn.jsdelivr.net/npm/ayu@9.1.0/dist/generated/mirage.js
    curl -sO https://cdn.jsdelivr.net/npm/ayu@9.1.0/dist/generated/light.js
    scripts/gen-palette.py --night dark.js --dusk mirage.js --day light.js

The command needs no network access of its own; the upstream sources are
`themes/{dark,mirage,light}.yaml' and `designer/lib/shiki-theme.ts' of
<https://github.com/ayu-theme/ayu-colors>, and the flavours map night=dark,
dusk=mirage, day=light.

What is derived here, and what is not
-------------------------------------

Everything that can be taken from the resolver output is taken as-is: the
`syntax.*' tokens, the `palette.*' ramps (l1..l5 of every hue), `terminal.*',
`vcs.*', `surface.*', `editor.*', `ui.*' and `common.*'.  Every other entry is
computed by `blend()', i.e. compositing an official colour at an alpha over the
flavour background, because an Emacs face takes opaque colours only:

  * selection / findMatch / editor.line come with their alpha encoded in the
    8 digit hex of the resolver output (e.g. `3388ff40'), so they are blended
    over the background;
  * the rest of the alphas are chosen here and are listed in build() below
    (10% for bg-alt, 18% for the diff backgrounds, 35% for the error and warning
    ones, 30% / 50% / 70% / 80% for the weaker foregrounds, 55% for accent-dim);
  * `comment-strong' is the foreground mixed halfway into the comment colour,
    and `fg-strong' is the foreground moved 60% toward white (dark flavours) or
    toward black (day);
  * the `syntax-*-strong' family is not from Ayu at all: it is the most
    contrasty end of the same hue ramp (l5 for the dark flavours, l1 for day),
    used only by the opt-in `ayu-themes-contrasted-syntax';
  * `warning' and `bg-warning' use `palette.yellow.l4', because Ayu has no
    warning token of its own;
  * `bg-sunk' of the night flavour is deliberately the classic ayu-dark
    background instead of the near-black `surface.sunk' of the official palette.

The output is the block to paste into `ayu-themes-palettes' plus the WCAG
contrast report printed from the same values; the report is what the Contrast
table of README.md is built from.  After a re-run, diff the block against
ayu-themes.el, update that table, and re-run the package checks.
"""

import argparse
import json
import re
import sys

LEAF = re.compile(r"^(\s*)([A-Za-z][\w]*):\s*new Color\('([0-9a-fA-F]{6,8})'\)")
OPEN = re.compile(r"^(\s*)([A-Za-z][\w]*):\s*\{\s*$")

# The sections of the resolver output this script reads.
REQUIRED = ('palette', 'syntax', 'terminal', 'vcs', 'surface', 'editor', 'ui',
            'common')


def parse(path):
    """Read one `dist/generated/*.js' file into nested dicts of hex strings."""
    root = {}
    stack = [(-1, root)]
    for line in open(path):
        if m := LEAF.match(line):
            indent, key, hexv = len(m.group(1)), m.group(2), m.group(3)
            while stack[-1][0] >= indent:
                stack.pop()
            stack[-1][1][key] = hexv
        elif m := OPEN.match(line):
            indent, key = len(m.group(1)), m.group(2)
            while stack[-1][0] >= indent:
                stack.pop()
            node = {}
            stack[-1][1][key] = node
            stack.append((indent, node))
        elif re.match(r"^\s*\},?\s*$", line):
            if len(stack) > 1:
                stack.pop()
    return root


def rgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def hexs(t):
    return '#%02x%02x%02x' % t


def blend(fg, alpha, bg):
    """Composite FG (hex or hex+alpha) over BG (solid hex)."""
    f = rgb(fg[:6])
    a = alpha if alpha is not None else (int(fg[6:8], 16) / 255 if len(fg) == 8 else 1.0)
    b = rgb(bg)
    return hexs(tuple(round(f[i] * a + b[i] * (1 - a)) for i in range(3)))


def lum(h):
    def ch(c):
        c /= 255
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    r, g, b = rgb(h)
    return 0.2126 * ch(r) + 0.7152 * ch(g) + 0.0722 * ch(b)


def contrast(a, b):
    la, lb = lum(a), lum(b)
    hi, lo = max(la, lb), min(la, lb)
    return (hi + 0.05) / (lo + 0.05)


RAMPS = ['gray', 'red', 'pink', 'orange', 'peach', 'yellow',
         'green', 'teal', 'indigo', 'blue', 'purple']

SYNTAX = {'syntax-tag': 'tag', 'syntax-func': 'func', 'syntax-entity': 'entity',
          'syntax-string': 'string', 'syntax-regexp': 'regexp', 'syntax-markup': 'markup',
          'syntax-keyword': 'keyword', 'syntax-special': 'special',
          'syntax-comment': 'comment', 'syntax-constant': 'constant',
          'syntax-operator': 'operator'}

TERM = ['black', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white',
        'brightBlack', 'brightRed', 'brightGreen', 'brightYellow',
        'brightBlue', 'brightMagenta', 'brightCyan', 'brightWhite']

# Which ramp step each syntax colour uses, per the official themes/*.yaml.
STEP = {
    'night': {'tag': ('indigo', 2), 'func': ('yellow', 4), 'entity': ('blue', 3),
              'string': ('green', 4), 'regexp': ('teal', 5), 'markup': ('red', 2),
              'keyword': ('orange', 3), 'special': ('peach', 4), 'comment': ('gray', 4),
              'constant': ('purple', 3), 'operator': ('pink', 3)},
    'dusk':  {'tag': ('indigo', 2), 'func': ('yellow', 4), 'entity': ('blue', 3),
              'string': ('green', 5), 'regexp': ('teal', 4), 'markup': ('red', 1),
              'keyword': ('orange', 2), 'special': ('peach', 3), 'comment': ('gray', 1),
              'constant': ('purple', 4), 'operator': ('pink', 2)},
    'day':   {'tag': ('indigo', 3), 'func': ('yellow', 4), 'entity': ('blue', 2),
              'string': ('green', 3), 'regexp': ('teal', 3), 'markup': ('red', 2),
              'keyword': ('orange', 3), 'special': ('peach', 3), 'comment': ('gray', 4),
              'constant': ('purple', 2), 'operator': ('pink', 4)},
}


def build(flavour, p):
    ed, surf, ui = p['editor'], p['surface'], p['ui']
    com = p['common']
    bg = ed['bg']
    fg = ed['fg']

    # Ayu's `surface.sunk' is a near-black for the dark flavour, which is too
    # harsh for fringes and gutters; fall back to the classic ayu-dark bg.
    dark = lum(bg) < 0.5
    sunk = '#0a0e14' if flavour == 'night' else surf['sunk']

    pal = {}
    pal['bg'] = bg
    pal['bg-dim'] = surf['base']
    pal['bg-sunk'] = sunk
    pal['bg-panel'] = ui['panel']['bg']
    pal['bg-popup'] = ui['popup']['bg']
    pal['bg-hl'] = blend(ed['line'], None, bg)
    pal['bg-alt'] = blend(fg, 0.10, bg)
    pal['bg-sel'] = blend(ed['selection']['active'], None, bg)
    pal['bg-sel-dim'] = blend(ed['selection']['inactive'], None, bg)
    pal['bg-match'] = ed['findMatch']['active']
    pal['bg-match-dim'] = blend(ed['findMatch']['inactive'], None, bg)
    pal['bg-error'] = blend(com['error'], 0.35, bg)
    pal['bg-warning'] = blend(p['palette']['yellow']['l4'], 0.35, bg)
    pal['bg-added'] = blend(p['vcs']['added'], 0.18, bg)
    pal['bg-changed'] = blend(p['vcs']['modified'], 0.18, bg)
    pal['bg-deleted'] = blend(p['vcs']['removed'], 0.18, bg)
    pal['bg-added-hl'] = blend(p['vcs']['added'], 0.38, bg)
    pal['bg-deleted-hl'] = blend(p['vcs']['removed'], 0.38, bg)

    pal['fg'] = fg
    pal['fg-strong'] = blend(fg, 0.60, '#ffffff' if dark else '#000000')
    pal['fg-dim'] = ui['fg']
    pal['fg-delim'] = blend(fg, 0.70, bg)
    pal['fg-faint'] = blend(ui['fg'], 0.80, bg)
    pal['fg-ghost'] = blend(ui['fg'], 0.50, bg)
    pal['comment-strong'] = blend(fg, 0.50, p['syntax']['comment'])

    pal['border'] = blend(ui['line'], None, bg)
    pal['border-strong'] = blend(fg, 0.30, bg)

    pal['accent'] = com['accent']['tint']
    pal['accent-dim'] = blend(com['accent']['tint'], 0.55, bg)
    pal['on-accent'] = com['accent']['on']

    pal['error'] = com['error']
    pal['warning'] = p['palette']['yellow']['l4']
    pal['success'] = p['vcs']['added']

    pal['vcs-added'] = p['vcs']['added']
    pal['vcs-modified'] = p['vcs']['modified']
    pal['vcs-removed'] = p['vcs']['removed']

    for key, name in SYNTAX.items():
        pal[key] = p['syntax'][name]
        ramp, step = STEP[flavour][name]
        # `strong' = the most contrasty end of the same ramp: the lightest
        # step for the dark flavours, the darkest step for the day flavour.
        pal[key + '-strong'] = p['palette'][ramp]['l%d' % (1 if not dark else 5)]

    for i, t in enumerate(TERM, 1):
        pal['term-' + re.sub(r'(?<!^)(?=[A-Z])', '-', t).lower()] = p['terminal'][t]

    for r in RAMPS:
        for i in range(1, 6):
            pal['%s-%d' % (r, i)] = p['palette'][r]['l%d' % i]

    return {'%s' % k: '#' + v.lstrip('#') for k, v in pal.items()}


def fmt_alist(pal, width=96):
    items = ['(%s "%s")' % (k, v) for k, v in pal.items()]
    lines, cur = [], ''
    for it in items:
        if not cur:
            cur = '   ' + it
        elif len(cur) + 1 + len(it) <= width:
            cur += ' ' + it
        else:
            lines.append(cur)
            cur = '   ' + it
    if cur:
        lines.append(cur)
    return '\n'.join(lines)


def load(flavour, path):
    p = parse(path)
    missing = [s for s in REQUIRED if s not in p]
    if missing:
        sys.exit('%s: %s does not look like the resolver output of the `ayu\' '
                 'package: no %s.  Fetch dist/generated/%s.js, not dist/%s.js '
                 '(that one is a 404).'
                 % (sys.argv[0], path, ', '.join(missing),
                    {'night': 'dark', 'dusk': 'mirage', 'day': 'light'}[flavour],
                    {'night': 'dark', 'dusk': 'mirage', 'day': 'light'}[flavour]))
    return build(flavour, p)


def main():
    ap = argparse.ArgumentParser(
        description='Generate the ayu-themes.el palettes from the official '
                    'ayu-colors resolver output.',
        epilog='The three files are dist/generated/{dark,mirage,light}.js of the '
               'npm package `ayu\'.  See the module docstring for the curl commands.')
    ap.add_argument('--night', metavar='FILE', required=True, help='dark flavour')
    ap.add_argument('--dusk', metavar='FILE', required=True, help='mirage flavour')
    ap.add_argument('--day', metavar='FILE', required=True, help='light flavour')
    ap.add_argument('--json', metavar='FILE',
                    help='also write the palette as JSON (for diffing)')
    args = ap.parse_args()

    out = {'night': load('night', args.night),
           'dusk': load('dusk', args.dusk),
           'day': load('day', args.day)}

    print(';;; ==== value of `ayu-themes-palettes\', ready to paste ====')
    parts = ['  (%s\n%s)' % (fl, fmt_alist(out[fl]))
             for fl in ('night', 'dusk', 'day')]
    # Wrap the three alists in the quoting list of the defconst: the file has
    # `  \'((night ...` on the first line and one more `)\' at the very end.
    print("  '(" + '\n\n'.join(parts)[2:] + ')')

    print(';;; ==== contrast report (WCAG) ====')
    for flavour in ('night', 'dusk', 'day'):
        p = out[flavour]
        bg = p['bg']
        print('--- %s (bg %s, fg %s) ---' % (flavour, bg, p['fg']))
        keys = (['fg', 'fg-dim', 'fg-faint', 'fg-delim', 'accent', 'border', 'error',
                 'warning', 'success', 'vcs-added', 'vcs-modified', 'vcs-removed'] +
                list(SYNTAX))
        row = []
        for k in keys:
            c = contrast(p[k], bg)
            row.append('%s=%.2f' % (k.replace('syntax-', ''), c))
        for i in range(0, len(row), 4):
            print('   ' + '  '.join(row[i:i + 4]))

    print()
    print(';;; ==== UI/bg sanity ====')
    for flavour in ('night', 'dusk', 'day'):
        p = out[flavour]
        print('%s: bg=%s bg-dim=%s bg-sunk=%s bg-hl=%s bg-alt=%s panel=%s popup=%s sel=%s match=%s border=%s'
              % (flavour, p['bg'], p['bg-dim'], p['bg-sunk'], p['bg-hl'], p['bg-alt'],
                 p['bg-panel'], p['bg-popup'], p['bg-sel'], p['bg-match'], p['border']))

    if args.json:
        with open(args.json, 'w') as fh:
            json.dump(out, fh, indent=1)


if __name__ == '__main__':
    main()
