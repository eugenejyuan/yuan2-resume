# Fonts

Fonts are four **semantic slots**, not four font names. Content refers to slots, so
selecting another local configuration touches no content. The project ships one
configuration and makes it the class default:

| Slot | Role | `fontset=commercial` |
|---|---|---|
| main | body text | Sabon LT Std |
| `\TitleFont` | name and contact block | Calluna |
| `\SectionFont` | section headings | Cronos Pro LT |
| `\CodeFont` | inline literals | Courier New |

```latex
\documentclass{yuan2resume}                     % commercial is the default
\documentclass[fontset=commercial]{yuan2resume} % equivalent, explicit spelling
```

## Install the commercial files

The font binaries are ignored by Git. Download the exact set used by the original
template from a pinned upstream commit and verify every SHA-256 checksum:

```bash
make fonts
```

The command creates:

```
fonts/
├── SabonLTStd/     SabonLTStd-Regular.ttf / -Bold.ttf / -Italic.ttf / -BoldItalic.ttf
├── Calluna/        Calluna-Regular.otf
├── CronosProLT/    CronosProLT-Regular.ttf
└── CourierNew/     CourierNew-Regular.ttf
```

See [`fonts/README.md`](../fonts/README.md) for the upstream source and licensing note.
You may also place properly licensed copies at those paths yourself. File names and
extensions are explicit in `configs/fonts-commercial.tex`; there is no extension
guessing. A missing upright file is a class error, so the selected font set can never
silently fall back to different metrics.

## Adding a font set

A font set is one file, `configs/fonts-<name>.tex`, selected by `fontset=<name>`. The
loader remains switchable even though the repository provides only `commercial`:

```latex
\ProvidesFile{fonts-mine.tex}[My Font Setup]
\defaultfontfeatures{Ligatures=TeX}

\cvrequirefont{fonts/mine/MySerif-Regular.otf}
\setmainfont{MySerif}[
  Path=fonts/mine/,
  Extension=.otf,
  UprightFont=*-Regular,
  BoldFont=*-Bold,
  ItalicFont=*-Italic,
  BoldItalicFont=*-BoldItalic
]

\cvrequirefont{fonts/mine/MyDisplay-Regular.otf}
\newfontfamily\TitleFont{MyDisplay}[
  Path=fonts/mine/,
  Extension=.otf,
  UprightFont=MyDisplay-Regular
]
\let\SectionFont\TitleFont

\cvrequirefont{fonts/mine/MyMono-Regular.otf}
\newfontfamily\CodeFont{MyMono}[
  Path=fonts/mine/,
  Extension=.otf,
  UprightFont=MyMono-Regular
]
```

Then select it with `\documentclass[fontset=mine]{yuan2resume}`. Keep custom font
binaries ignored or manage their licences explicitly.

`\cvrequirefont` guards the one upright file a slot needs -- declare it for every
slot, as above. The remaining declarations are ordinary `fontspec`, so adding a set
does not depend on private class macros or an extension-detection callback layer.

## Why XeLaTeX

The class requires XeLaTeX and rejects pdfLaTeX or LuaLaTeX before loading a font set —
one supported rendering path, and the build engine is part of the contract. The
consequence for font paths is in [`DESIGN.md`](DESIGN.md#one-engine): every build must
run from the repository root.
