# The yuan2resume Grammar

Reference for writing content. The seven primitives, the six invariants they must
preserve, and what to do when the page misbehaves.

The [README](../README.md) says what the project is; [`DESIGN.md`](DESIGN.md) says why
each invariant holds and shows the measurements. Neither is needed to write a resume.

## The primitives

```latex
\begin{cvtwocolumn}[<ratio>]   % container; label rail defaults to 0.18
\begin{cvsection}{<heading>}   % one row of the grammar: label left, content right
\cvpair{<left>}{<right>}       % full-width line, right cell flush right
\cvgap[<n>]                    % one unit of separation between sibling entries
\begin{cventry}[<indent>]      % nested sub-unit; indents from the left only
\begin{cvitemize}              % bullet list
\begin{cvnumlist}              % numbered list, digit-aligned
```

`cvsection` must appear inside `cvtwocolumn`; everything else must appear inside a
`cvsection`. Plain paragraphs are legal inside `cvsection` too — the Skills section in
`main.tex` is text with `\\` breaks and no list at all, which is often the densest way to
present a category-value block.

### `cventry`: one level down

Use it when something belongs *to* the entry above rather than beside it — a project
under a job, a thesis under a degree:

```latex
\cvpair{\textbf{[Employer or Lab]}}{[City, Country]}
\cvpair{\textbf{[Role]}, [Group or Team]}{2022 -- \textit{Present}}
\begin{cvitemize}
  \item What you owned, in one line, with the scope made legible.
\end{cvitemize}
\begin{cventry}
  \cvpair{\textit{[Project or Workstream]}}{2023 -- 2024}
  \begin{cvitemize}
    \item The result, and the number that makes it checkable.
  \end{cvitemize}
\end{cventry}
```

It may contain anything a `cvsection` may, including another `cventry`. Pass an explicit
step — `\begin{cventry}[2.4em]` — only when one block genuinely needs to differ.

Do not confuse it with `\cvgap`: `\cvgap` separates **siblings** at the same level,
`cventry` opens a **child** level underneath one. The next job is a sibling; a project
belonging to that job is a child.

## The six invariants

**1. The left track carries labels only.** `cvsection` jumps to column 0, writes the
heading, and switches to column 1; all content lives in the right column. At
`columnratio` 0.18 the rail is narrow, so long headings need explicit breaks:
`\begin{cvsection}{Awards\\and\\Honors}`.

**2. `\cvpair` is the only way to align left against right.** Every `\cvpair` is a
`tabularx` spanning the full `\linewidth`, so every date and location in the document
lands on one shared right edge — at any nesting depth. Never use `\hfill`,
`\hspace*{\fill}`, a bare `tabular`, or a `minipage` pair.

**3. Both list types share one left margin.** `cvitemize` and `cvnumlist` are built on
the same `\cvitemleftmargin` (1.2em) and `\cvlabelsep` (0.4em), so you can alternate
between them inside a section and nothing shifts. `cvnumlist` reserves width for two
digits, so items 9 and 10 do not jog; past 99 entries, raise `widest`. `\cventryindent`
defaults to `\cvitemleftmargin`, so an indented `cventry` starts exactly where a bullet's
text starts — a section has **one** nested left edge, not two competing ones.

**4. Vertical rhythm is measured in `\baselineskip`, never in points.** `\cvsectiontopsep`
(0.1), `\cvsectionbottomsep` (1.0), `\cventrysep` (0.3) and `\cvitemsep` (0.12) are all
multiples of a line. To change spacing, change the length — not the content.

**5. Entry separation is explicit.** `cvsection` cannot know where one entry ends and the
next begins, because it does not constrain what goes inside it. Write the separation
yourself:

```latex
\begin{cvsection}{Education}
  \cvpair{\textbf{[Doctoral Institution]}}{[City, Country]}
  \cvpair{\textit{Ph.D. in [Field]}}{2020 -- Present}
  \cvgap                        % <- required between sibling entries
  \cvpair{\textbf{[Undergraduate Institution]}}{[City, Country]}
  \cvpair{\textit{B.S. in [Field]}}{2016 -- 2020}
\end{cvsection}
```

This is the single most commonly forgotten construct in the grammar; omit it and two jobs
visually merge into one. `\cvgap[2]` gives a stronger break without leaving the rhythm.
It is the only way content may add vertical space — **a resume file contains no `\vspace`
at all**, not even `\vspace{\cventrysep}`.

**6. Fonts and icons are semantic slots, not names.** Content refers to `main`,
`\TitleFont`, `\SectionFont`, `\CodeFont` and to `\cvIconScholar`, `\cvIconGitHub`, …, so
another font set or another glyph restyles the whole document without touching a line of
content. Use `{\CodeFont Python}` for things that are literally code, not as generic
emphasis. See [`FONTS.md`](FONTS.md).

## Identity and class options

```latex
\documentclass[fontset=commercial, pagefooter=false, icons=true]{yuan2resume}

\cvname{[Full Name]}                     % required -- omitting it is an error
\cvposition{[Ph.D. Candidate]}           % optional, inline after the name

\cvcontactrow{                           % everything inside shares ONE row
  \cvcontact[\cvIconPhone]{[+00 0000 0000]}
  \cvemail{name@example.edu}             % icon defaults to \cvIconEmail
}
\cvcontactrow{
  \cvlink[\cvIconScholar]{https://example.edu/scholar}{Scholar}
  \cvlink[\cvIconGitHub]{https://example.com/git}{git/handle}
  \cvlink[\cvIconSite]{https://example.org}{example.org}
}
```

The contact block is an **ordered stack of explicit rows, not a fixed set of fields**:

- Items print in **declaration order**. To reorder them, reorder the lines; to move one
  between rows, move its line.
- Every item must be inside a `\cvcontactrow`. Bare items, empty rows, and nested rows
  are structural errors.
- There is no upper bound and no fixed vocabulary. ORCID, ResearchGate, a postal address
  — all are `\cvlink` with a different icon slot.

Available icon slots: `\cvIconPhone`, `\cvIconEmail`, `\cvIconSite`, `\cvIconLocation`,
`\cvIconScholar`, `\cvIconGitHub`, `\cvIconLinkedIn`. Rebind one with `\renewcommand`;
any `fontawesome5` command also works inline. `icons=false` drops them all.

`\cvname` is the one **required** field: `\maketitle` and `pagefooter=true` both
print it, and each raises a class error rather than typesetting a nameless header
or a footer reading `· 1/2`.

`pagefooter=true` prints `Name · page/total` centered at the foot. It resolves the total
via `lastpage`, so it needs two passes — `latexmk` handles that. Off by default.

The pre-0.4 spellings `\name`, `\position`, `\phone`, `\email`, `\homepage` are no longer
defined.

## Tuning knobs

Set these in the preamble, after `\documentclass`, when the default proportions do not
suit the content:

```latex
\setlength{\cvsectionbottomsep}{0.8\baselineskip}  % tighten section gaps
\setlength{\cventrysep}{0.4\baselineskip}          % loosen entry gaps
\setlength{\cvitemleftmargin}{1.0em}               % pull bullets left
\setlength{\cventryindent}{1.6em}                  % deepen the nesting step
\begin{cvtwocolumn}[0.22]                          % widen the label rail
```

Prefer one global adjustment over sprinkling local corrections. If a resume needs many
local corrections, the content is fighting the grammar and should be rewritten instead.
Changing `\linespread` needs the lengths re-issued — see the caveat in
[`DESIGN.md`](DESIGN.md).

## What breaks

| Symptom | Cause |
|---|---|
| Dates almost but not quite aligned | Hand-rolled `\hfill` instead of `\cvpair` |
| Two jobs read as one | Missing `\cvgap` between entries |
| Spacing drifts down the page | Absolute `\vspace{Npt}` mixed into the rhythm |
| Text runs into the right margin | Overfull `\hbox`: usually a bare URL or long compound. Rewrite, or wrap in `\href{}{}` |
| A nested project's date breaks the right edge | Indented with `\hspace`/`\leftskip` instead of `cventry` |
| Section heading wraps badly | The rail is 0.18 wide; add `\\` breaks or widen the ratio |
| Heading letters look wrong | Manual `\textsc{}` or ALL CAPS on top of the class's small caps |
| Compile hangs or misplaces content | `\newpage`, a float, or a footnote inside `paracol` |
| `cvsection used outside cvtwocolumn` | `cvsection` needs the two columns to switch between |
| `cvsection nested inside cvsection` | Sections are siblings; for a sub-unit use `cventry` |
| `cvtwocolumn cannot be nested` | One container wraps the whole resume |
| `<X> is inside cvtwocolumn but outside any cvsection` | The content would land in the 0.18 label rail |
| `cvcontact used outside cvcontactrow` | Every contact item needs an explicit row |
| `empty cvcontactrow` / `cvcontactrow cannot be nested` | Contact rows must be non-empty siblings |
| `cvname is required by <X>` | `\cvname` is missing, and `<X>` prints it |
| `Font file not found` | The selected font set is incomplete — run `make fonts` |
| Build stops before content | Wrong engine, or the build did not run from the repository root |

Overfull `\hbox` is a *warning*: the PDF still builds and the compile exits zero. Run
`make check`, and then `make png` and look at the page.
