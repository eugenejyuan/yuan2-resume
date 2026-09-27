# AGENTS.md

`yuan2resume` is a **typographic grammar** for résumés, not a fill-in-the-blank template.
Seven primitives compose freely, and the layout stays aligned as long as nothing
bypasses them. `main.tex` is a skeleton, not the required shape of a resume;
`examples/` holds two more that share no section list. Every identity in them is a
bracketed placeholder: they show structure and assert nothing about anyone.

## Building a résumé

1. **Get the material.** Content comes from the person: an old CV, a LinkedIn export,
   notes, answers to your questions. Never invent a fact, a date or a number; ask. No
   check can catch a fabricated line.
2. **`make fonts`**, once after cloning.
3. **Read [`docs/GRAMMAR.md`](docs/GRAMMAR.md).** It is the whole vocabulary: what
   nests in what, which primitive fits which content, the defaults and the knobs.
4. **Write `main.tex`**, the only file you edit. Build the sections this person's
   history actually has.
5. **`make check`** until it exits zero.
6. **`make png`, and look at every page.** Every right-hand value of `\cvpair` sits
   flush against the right margin, every heading sits in the left rail, and no page is
   less than a third full. No script can check whether a page reads well.

## When the page is wrong

Fix it in this order, and stop at the first step that works:

1. **The content.** Too long: cut prose. An overfull line: shorten it. A crowded
   header: shorten a contact label.
2. **One global knob** in the preamble, from
   [Defaults and knobs](docs/GRAMMAR.md#defaults-and-knobs).
3. **A primitive's own argument**, for one place: `\cvgap[2]`, `\begin{cventry}[2.4em]`.

Content never spaces, sizes or aligns anything by hand: no `\vspace`, `\hspace`,
`\hfill`, `\\[..]`, `\small`, `\geometry`, `\section`, `itemize`, `tabular` or
`minipage`. Each has a primitive that does its job, and `make check` rejects them.
Never edit `yuan2resume.cls` or `configs/` to make content fit; rewrite the content.

Escape `& % $ # _` as usual (`R\&D`, `95\%`, `C\#`), and write date ranges with `--`.
An unescaped `%` silently deletes the rest of its line, and no check catches it.

## Definition of done

`make check` exits zero. It enforces: the document builds; no overfull `\hbox`; every
font found; no `Class yuan2resume Error`; page count within budget; no hand spacing,
sizing or alignment; no placeholder left. A class error means the composition is wrong,
and the log shows its fix right under it. Step 6 is still yours.

## Commands

XeLaTeX (TeX Live / MacTeX), always run from the repository root. `make fonts` also
needs `curl`.

```bash
make          # build main.tex into build/
make check    # the definition of done; non-zero exit if not shippable
make png      # render every page to build/page-N.png
make fonts    # download and verify the commercial fonts
make test     # class contract tests, including expected failures
make examples # build and check every examples/*.tex (page budget 2)
make preview  # regenerate the README résumé preview from examples/academic.tex

PAGES=2 scripts/check.sh main.tex   # raise the page budget for a CV
```

## Changing the class, docs or examples

Read [`docs/DESIGN.md`](docs/DESIGN.md) first. `make test` and `make examples` must pass.

| Path | Role |
|---|---|
| `yuan2resume.cls` | The grammar itself. |
| `configs/fonts-*.tex` | Font sets, selected by `fontset`; see [`docs/FONTS.md`](docs/FONTS.md). |
| `examples/*.tex` | Placeholder skeletons. Every identity stays a bracketed slot. |
| `scripts/check.sh` | The definition of done, executable. |
| `scripts/test.sh` | Positive and negative contract tests for the class and the check. |
| `assets/font-commercial.png` | A render of `examples/academic.tex`. Regenerate it with `make preview`; never hand-make or hand-edit it. |
| `assets/primitives.png` | Hand-drawn: it shows the grammar, not a person. Keep it compressed. |
