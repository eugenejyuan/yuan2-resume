# Design Notes

Why the grammar is shaped the way it is, and the measurements that back it. Nothing
here is needed to write a resume — [`GRAMMAR.md`](GRAMMAR.md) is. This file exists so
the invariants can be audited rather than believed.

## The shared right edge survives nesting

Invariant: `\cvpair` is the only construct allowed to align left against right, so every
date and location in the document lands on one edge.

`cventry` is built on LaTeX's `list`, which narrows `\linewidth` from the left only.
`\cvpair` is a `tabularx` measured against `\linewidth`, so it narrows in step and its
right cell does not move. Measured:

| nesting | left edge | line width | **right edge** |
|---|---|---|---|
| section body | 0.00pt | 412.56pt | **412.56pt** |
| inside one `cventry` | 13.14pt | 399.42pt | **412.56pt** |
| inside two | 26.28pt | 386.28pt | **412.56pt** |

This is the whole mechanism. Indenting by hand with `\hspace`, `\leftskip`, or a
`minipage` moves the left edge without narrowing `\linewidth`, and the right edge goes
with it.

The failure mode of a hand-rolled `\hfill` is worse than it looks: it produces an edge
that is *almost* right, which reads as sloppy rather than as deliberate.

## `\cvgap` merges; `\vspace` stacks

Invariant: content adds vertical space only through `\cvgap`.

`\cvgap` is built on `\addvspace`, which takes the maximum of the space already present
and the space requested instead of adding to it. A list has already contributed
`\cvitemsep` below itself; a `\cvpair` has not. `\addvspace` absorbs that difference, so
a sibling gap is the same size wherever it appears. Measured with `\cvitemsep` inflated
to 10pt to make the difference legible:

| separator | after a list | after a `\cvpair` |
|---|---|---|
| `\cvgap` | 36pt | 35pt |
| `\vspace{\cventrysep}` (the pre-0.3 idiom) | **46pt** | 35pt |

The second consequence is that the rule becomes checkable by *shape*. Because `\cvgap`
covers every legitimate case and cannot express an absolute length, "no `\vspace` in a
content file" is now a grep, not an argument:

```bash
grep -n '\\vspace' main.tex     # must print nothing
```

`scripts/check.sh` runs exactly that, after stripping comments.

## Vertical rhythm, and one caveat

Every vertical length in the class is declared as a multiple of `\baselineskip`:

| Length | Default |
|---|---|
| `\cvsectiontopsep` | `0.1\baselineskip` |
| `\cvsectionbottomsep` | `1.0\baselineskip` |
| `\cventrysep` | `0.3\baselineskip` |
| `\cvitemsep` | `0.12\baselineskip` |

so the page holds together when the base font size changes. Inject one absolute
`\vspace{4pt}` and the guarantee is gone: the rhythm stops scaling and the error
compounds down the page.

**Caveat, currently true:** `\setlength` evaluates its argument immediately, so these are
**load-time snapshots**, not live expressions. A `\linespread{1.5}` set in the preamble
changes `\baselineskip` *after* the class has already resolved `\cvsectionbottomsep` to
0.77 of the new line. Re-issue the `\setlength` yourself after changing `\linespread`, or
see the tuning knobs in [`GRAMMAR.md`](GRAMMAR.md). Fixing this properly means
recomputing at `\AtBeginDocument`; it is deferred, not overlooked.

## The guards are deliberately narrow

The class raises named errors for misuse that `paracol` would otherwise accept silently
or report as a bare `! Undefined control sequence`. They fire **only inside
`cvtwocolumn`**: `\cvpair` or `cvitemize` used in a plain document is legal and silent,
because nothing about it is broken. A guard that fires on legitimate use trains people
to work around guards.

`Font file not found` is the one that mattered most. Before it existed, a missing font
file produced no diagnostic at all — fontspec fell back to different metrics and the
layout was quietly wrecked. `\cvrequirefont` checks the one upright file every slot
needs, and there is no extension guessing anywhere in `configs/`.

Overfull `\hbox` is a *warning*: the PDF still builds and xelatex still exits zero. It is
the single most likely defect to ship unnoticed, which is why `scripts/check.sh` treats
it as a hard failure.

## The contact block is a stack, not a record

An earlier version had five fixed fields (`\name`, `\position`, `\phone`, `\email`,
`\homepage`). Fixed fields have two defects: an undeclared field can leave a gap, and
every new kind of link needs a new command.

The replacement is an ordered stack of explicit rows. Items print in declaration order,
so reordering means reordering lines, and there is no fixed vocabulary — ORCID,
ResearchGate, a postal address are all `\cvlink` with a different icon slot.

`\cvphone` and `\cvhomepage` were deliberately **not** added as conveniences. Neither
expresses anything `\cvcontact` and `\cvlink` do not already express; a primitive that
only aliases a composition of existing primitives adds vocabulary without adding power.

`\cvname` is the one field that survived as required, so it is the one field with a
guard. It is checked at each place that prints it — `\maketitle` and the page footer —
rather than once at `\begin{document}`, because a document that never calls `\maketitle`
and never turns the footer on genuinely does not need a name. Unguarded it failed
silently in both directions: an empty line above the header rule, and a footer reading
`· 1/2`.

Icons follow the same rule as fonts: content names a **role** (`\cvIconScholar`), never a
glyph. Rebinding one slot restyles every resume.

`fontawesome5` is optional — absent, the class warns once and the slots expand to
nothing, so the document still builds. Google Scholar deliberately does *not* use
`academicons`: that package ships an `\aiGoogleScholar` whose codepoint is missing from
the font it ships with, so it silently typesets a blank.

## The header sizes itself

`\maketitle` gives the contact block its **natural width** and the name whatever is left,
rather than splitting the line on a fixed ratio. Adding a contact item reflows the header
instead of requiring a retune.

`\cvheadsep` is unshrinkable on purpose. A near-collision between the name and the
contact block therefore reports as `Overfull \hbox` instead of silently letting the two
touch — and the fix is a shorter label (`Scholar`, not `Google Scholar`), never a smaller
`\cvheadsep`.

## One engine

XeLaTeX is part of the rendering contract, not a preference. Other engines are rejected
before a font set loads. One supported path means the font configuration can use
`fontspec` `Path=` directly, and a resume that builds is a resume that builds the same
way everywhere.

The cost is that font files resolve against the **compiler's working directory**: every
build must run from the repository root. `make`, `scripts/check.sh`, and `scripts/test.sh`
all `cd` there themselves; an editor integration has to be told to.
