# The yuan2resume Grammar

Reference for writing content: what nests in what, which primitive fits which content,
the six invariants that keep the layout aligned, and the defaults you may tune.

The [README](../README.md) says what the project is; [`DESIGN.md`](DESIGN.md) says why
each invariant holds and shows the measurements. Neither is needed to write a resume.

## Structure

The whole vocabulary, nested the way it may be used:

```latex
% preamble
\documentclass[fontset=commercial, pagefooter=false, icons=true]{yuan2resume}
\cvname{<name>}                      % required
\cvposition{<title>}                 % optional, inline after the name
\cvcontactrow{                       % one printed row; as many rows as you need
  \cvcontact[<icon>]{<text>}         % items exist only inside a row,
  \cvemail{<address>}                % and print in declaration order
  \cvlink[<icon>]{<url>}{<label>}
}

% body
\maketitle
\begin{cvtwocolumn}[<ratio>]         % exactly one; label rail defaults to 0.18
  \begin{cvsection}{<heading>}       % siblings only, never nested
    \cvpair{<left>}{<right>}         % full-width line, right cell flush right
    \cvgap[<n>]                      % separation between sibling entries
    \begin{cvitemize} \item ... \end{cvitemize}   % bullets
    \begin{cvnumlist} \item ... \end{cvnumlist}   % numbers, digit-aligned
    plain text, lines joined with \\
    \begin{cventry}[<indent>]        % a child of the entry above: holds anything
      ...                            % a cvsection holds, another cventry included
    \end{cventry}
  \end{cvsection}
\end{cvtwocolumn}
```

The seven primitives are `cvtwocolumn`, `cvsection`, `\cvpair`, `\cvgap`, `cventry`,
`cvitemize` and `cvnumlist`; the rest is identity. A primitive in the wrong place is a
named class error, not a silent misalignment.

## Composing content

`main.tex` is a skeleton, not the required shape of a resume: build the sections this
person's history actually has. Each kind of content has one composition:

| The content is | Compose it as |
|---|---|
| An entry: a job, a degree, a lab | `\cvpair{<org>}{<place>}`, `\cvpair{<role>}{<dates>}`, then `cvitemize` |
| The next entry at the same level | `\cvgap`, then the entry |
| Part of the entry above: a project under a job, a thesis under a degree | Wrap it in `cventry` |
| Dated one-liners: awards, talks, grants | One `\cvpair` per line, no `\cvgap` |
| Numbered items: publications, patents | `cvnumlist` |
| Label–value lines: skills, languages | Plain text: `\textbf{<Label>}: <values> \\` |
| A heading too long for the rail | Break it: `{Awards\\and\\Honors}` |

An entry, a child, and a sibling together:

```latex
\begin{cvsection}{Experience}
  \cvpair{\textbf{[Employer]}}{[City, Country]}
  \cvpair{\textbf{[Role]}, [Team]}{2022 -- \textit{Present}}
  \begin{cvitemize}
    \item What you owned, in one line, with the scope made legible.
  \end{cvitemize}
  \begin{cventry}                  % child: belongs to the role above
    \cvpair{\textit{[Project]}}{2023 -- 2024}
    \begin{cvitemize}
      \item The result, and the number that makes it checkable.
    \end{cvitemize}
  \end{cventry}
  \cvgap                           % sibling: the next role
  \cvpair{\textbf{[Earlier Employer]}}{[City, Country]}
  \cvpair{\textbf{[Role]}}{2019 -- 2022}
\end{cvsection}
```

`\cvgap` separates **siblings**; `cventry` opens a **child** level. Forgetting `\cvgap`
is the most common mistake in the grammar: two jobs visually merge into one.

## The six invariants

**1. The left track carries labels only.** `cvsection` writes its heading into the rail
and switches to the content column; all content lives on the right. The rail is narrow,
so long headings need explicit `\\` breaks.

**2. `\cvpair` is the only way to align left against right.** It is a `tabularx`
spanning the full `\linewidth`, so every date and location lands on one shared right
edge at any nesting depth. `\hfill`, `\hspace*{\fill}`, a bare `tabular` or a `minipage`
pair produce an edge that is *almost* right.

**3. Both lists share one left margin.** `cvitemize` and `cvnumlist` are built on the
same `\cvitemleftmargin` and `\cvlabelsep`, so they can alternate and nothing shifts.
`cvnumlist` reserves two digits, so items 9 and 10 do not jog; past 99, raise `widest`.
`\cventryindent` defaults to `\cvitemleftmargin`, so a `cventry` starts where bullet text
starts: a section has **one** nested left edge, not two.

**4. Vertical rhythm is measured in `\baselineskip`, never in points.** Every vertical
length is a multiple of a line, so the page holds together when the type changes. One
absolute `\vspace{4pt}` and the rhythm stops scaling.

**5. Entry separation is explicit, and `\cvgap` is the only way to add space.**
`cvsection` cannot know where one entry ends, so write `\cvgap` between siblings;
`\cvgap[2]` gives a stronger break. It merges with space already present instead of
stacking on it, which is why a resume file contains no `\vspace` at all.

**6. Fonts and icons are semantic slots, not names.** Content refers to `\TitleFont`,
`\SectionFont`, `\CodeFont` and to icon slots such as `\cvIconGitHub`, so another font
set or glyph restyles the document without touching content. Use `{\CodeFont Python}`
only for things that are literally code. See [`FONTS.md`](FONTS.md).

## Identity

The contact block is an **ordered stack of explicit rows**, not a fixed set of fields.
Items print in declaration order: to reorder them, reorder the lines. Every item sits
inside a `\cvcontactrow`. There is no fixed vocabulary: ORCID, a portfolio, a postal
address are all `\cvlink` (or `\cvcontact` for plain text) with an icon.

Icon slots: `\cvIconPhone`, `\cvIconEmail` (the `\cvemail` default), `\cvIconSite`,
`\cvIconLocation`, `\cvIconScholar`, `\cvIconGitHub`, `\cvIconLinkedIn`. Use the slot
when one exists; for a service without one, pass the `fontawesome5` command directly:
`\cvlink[\faOrcid]{...}{...}`.

`\cvname` is **required**: `\maketitle` and `pagefooter=true` both print it, and each
raises a class error without it. `pagefooter=true` prints `Name · page/total`, which
needs two passes; `latexmk` handles that. The pre-0.4 spellings `\name`, `\position`,
`\phone`, `\email` and `\homepage` are gone.

## Defaults and knobs

The page itself is fixed: 11pt type, 0.7in margins, `\linespread{1.15}`. Everything
that may be tuned is below. Set lengths in the preamble, after `\documentclass`:

| To change | Set | Default |
|---|---|---|
| Space between sibling entries | `\setlength{\cventrysep}{0.4\baselineskip}` | `0.3\baselineskip` |
| Space after, before a section | `\cvsectionbottomsep`, `\cvsectiontopsep` | `1.0`, `0.1\baselineskip` |
| Space between list items | `\cvitemsep` | `0.12\baselineskip` |
| Bullet indent, label gap | `\cvitemleftmargin`, `\cvlabelsep` | `1.2em`, `0.4em` |
| Nesting step | `\cventryindent` | `\cvitemleftmargin` |
| Label rail width | `\begin{cvtwocolumn}[0.22]` | `0.18` |
| Paper size | class option `a4paper` | US letter |
| Page footer | class option `pagefooter=true` | off |
| Contact icons | `icons=false`, or rebind: `\renewcommand{\cvIconSite}{\faHome}` | on |
| Font set | `fontset=<name>`, see [`FONTS.md`](FONTS.md) | `commercial` |
| Page budget | `PAGES=2 scripts/check.sh main.tex` | 1 page |

For one place rather than the whole document, a primitive takes an argument:
`\cvgap[2]`, `\begin{cventry}[2.4em]`.

Prefer one global knob to many local corrections. If a resume needs many, the content
is fighting the grammar and should be rewritten instead. The header lengths
`\cvheadsep` (1.5em) and `\cvcontactsep` (1.2em) are not fitting tools: an overfull
header means a contact label is too long (`Scholar`, not `Google Scholar`).

## What breaks

A primitive in the wrong place stops the build with a class error that names the fix,
and `make check` names every line that spaces, sizes or aligns by hand. What is left is
what only the rendered page shows:

| Symptom | Cause |
|---|---|
| Two jobs read as one | Missing `\cvgap` between sibling entries |
| Text runs into the right margin | A bare URL or a long compound: wrap URLs in `\href{url}{label}`, rewrite the rest |
| Section heading wraps badly | The rail is narrow: add `\\` breaks, or widen the ratio |
| Heading letters look wrong | Manual `\textsc{}` or ALL CAPS on top of the class's small caps |
| Build stops before any content | Wrong engine, or the build did not run from the repository root |

Overfull `\hbox` is a *warning*: the PDF still builds. Run `make check`, and then
`make png` and look at the page.
