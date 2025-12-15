\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{yuan2resume}[2025/12/15 v0.1.0 Yuan2Resume class]

\RequirePackage{kvoptions}
\SetupKeyvalOptions{
  family=YR,
  prefix=YR@,
  setkeys=\kvsetkeys
}

% Declare fontset option with default value
\DeclareStringOption[default]{fontset}

% Process options: pass to article class and parse key-value pairs
\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessKeyvalOptions*

\LoadClass[11pt]{article}
\RequirePackage[margin=0.7in]{geometry}

% Set base line spacing (adjust as needed; 1.0 is default single spacing)
\linespread{1.15}

\RequirePackage{paracol}
\RequirePackage{tabularx}
\RequirePackage{enumitem}
\RequirePackage{xparse}
\RequirePackage{xstring}
\RequirePackage[hidelinks,pdfpagelabels=false]{hyperref}

% ====================================================================
% Font configuration
% ====================================================================

% ---- Font file finder and executor ----
% Arguments: #1=path, #2=family, #3=upright, #4=callback_macro, #5=extra_args_for_callback
\newcommand{\YR@FindFontAndExec}[5]{%
  % Ensure path ends with /
  \def\YR@temppath{#1}%
  \ifx\YR@temppath\@empty
     \def\YR@fontpath{}%
  \else
     \IfEndWith{\YR@temppath}{/}{%
       \def\YR@fontpath{#1}%
     }{%
       \def\YR@fontpath{#1/}%
     }%
  \fi
  %
  % Detect file extension and call callback function
  % Callback signature: \Callback{path}{extension}{family}{upright}{...extra_args}
  \IfFileExists{\YR@fontpath#2#3.otf}{%
    #4{\YR@fontpath}{.otf}{#2}{#3}#5%
  }{%
    \IfFileExists{\YR@fontpath#2#3.ttf}{%
      #4{\YR@fontpath}{.ttf}{#2}{#3}#5%
    }{%
      \IfFileExists{\YR@fontpath#2#3.OTF}{%
        #4{\YR@fontpath}{.OTF}{#2}{#3}#5%
      }{%
        \IfFileExists{\YR@fontpath#2#3.TTF}{%
           #4{\YR@fontpath}{.TTF}{#2}{#3}#5%
        }{%
          \ClassWarning{yuan2resume}{Font file not found: \YR@fontpath#2#3.{otf,ttf...}}%
        }%
      }%
    }%
  }%
}

% ---- Core configuration: build fontspec options ----
% Helper macro to generate [Path=..., BoldFont=...] option string
% Centralized here to avoid code duplication
\newcommand{\YR@BuildFontOptions}[6]{%
    Path = #1,
    Extension = #2,
    UprightFont = *#3%
    \expandafter\ifx\expandafter\relax\detokenize{#4}\relax\else, BoldFont = *#4\fi
    \expandafter\ifx\expandafter\relax\detokenize{#5}\relax\else, ItalicFont = *#5\fi
    \expandafter\ifx\expandafter\relax\detokenize{#6}\relax\else, BoldItalicFont = *#6\fi
}

% ---- Setup callback functions ----

% Callback A: Define new font family (replaces \YR@SetupFontFamily)
% Arguments: {path}{ext}{family}{upright}{cmd_name}{bold}{italic}{bolditalic}
\newcommand{\YR@SetupNamedFont}[8]{%
  \expandafter\newfontfamily\csname #5\endcsname{#3}[%
    \YR@BuildFontOptions{#1}{#2}{#4}{#6}{#7}{#8}%
  ]%
}

% Callback B: Set main font
% Arguments: {path}{ext}{family}{upright}{bold}{italic}{bolditalic}
% Note: No cmd_name parameter here
\newcommand{\YR@SetupMainFont}[7]{%
  \setmainfont{#3}[%
    \YR@BuildFontOptions{#1}{#2}{#4}{#5}{#6}{#7}%
  ]%
}

% ---- User interface commands ----

% Interface A: Load local font as new command
% Usage: \YR@TryLocalFontFile[path]{cmdname}{family}{upright}[bold][italic][bolditalic]
\NewDocumentCommand{\YR@TryLocalFontFile}{O{fonts/} m m m O{} O{} O{}}{%
  % Call finder with \YR@SetupNamedFont as callback
  % Extra arguments: {#2=cmdname}{#5=bold}{#6=italic}{#7=bolditalic}
  \YR@FindFontAndExec{#1}{#3}{#4}{\YR@SetupNamedFont}{{#2}{#5}{#6}{#7}}%
}

% Interface B: Load local font as main font
% Usage: \YR@SetMainFontFile[path]{family}{upright}[bold][italic][bolditalic]
% Note: One less argument than above (no cmdname parameter)
\NewDocumentCommand{\YR@SetMainFontFile}{O{fonts/} m m O{} O{} O{}}{%
  % Call finder with \YR@SetupMainFont as callback
  % Extra arguments: {#4=bold}{#5=italic}{#6=bolditalic}
  \YR@FindFontAndExec{#1}{#2}{#3}{\YR@SetupMainFont}{{#4}{#5}{#6}}%
}

% ---- Compiler compatibility pdfLaTeX fallback ----
\RequirePackage{iftex}

% Detect compiler type and handle pdfLaTeX compatibility
\ifpdftex
  \ClassWarning{yuan2resume}{%
    ================================================================^^J%
    WARNING: WRONG COMPILER DETECTED!^^J%
    ================================================================^^J%
    This template REQUIRES XeLaTeX or LuaLaTeX.^^J%
    You are currently using pdfLaTeX.^^J%
    ^^J%
    Custom fonts will NOT work correctly with pdfLaTeX.^^J%
    The document will compile but with fallback fonts.^^J%
    ^^J%
    TO FIX: Use XeLaTeX instead:^^J%
    \space\space xelatex main.tex^^J%
    ^^J%
    Or in Overleaf: Settings -> Compiler -> XeLaTeX^^J%
    ================================================================%
  }
  % pdfLaTeX does not support fontspec, use traditional font packages
  \RequirePackage[T1]{fontenc}
  \RequirePackage{lmodern}
  % Define default font commands (fallback to standard LaTeX font families)
  \newcommand{\TitleFont}{\rmfamily}
  \newcommand{\SectionFont}{\rmfamily}
  \newcommand{\CodeFont}{\ttfamily}
\else
  % XeLaTeX/LuaLaTeX path: use fontspec for custom font loading
  \RequirePackage{fontspec}
  \newcommand{\YR@fontconfig}{configs/fonts-\YR@fontset.tex}

  \IfFileExists{\YR@fontconfig}{%
    \input{\YR@fontconfig}%
  }{%
    \ClassError{yuan2resume}{%
      Font config file '\YR@fontconfig' not found.
      Please check if 'configs/fonts-\YR@fontset.tex' exists%
    }{%
      Check your spelling of the 'fontset' option or ensure the file exists.%
    }%
  }
\fi

% ====================================================================
% Title and contact information
% ====================================================================
\makeatletter
\def\YR@name{}
\def\YR@position{}
\def\YR@phone{}
\def\YR@email{}
\def\YR@homepage{}

\newcommand{\name}[1]{\gdef\YR@name{#1}}
\newcommand{\position}[1]{\gdef\YR@position{#1}}
\newcommand{\phone}[1]{\gdef\YR@phone{#1}}
\newcommand{\email}[1]{\gdef\YR@email{#1}}
\newcommand{\homepage}[1]{\gdef\YR@homepage{#1}}

\newcommand{\YR@ifempty}[3]{%
  \if\relax\detokenize{#1}\relax #2\else #3\fi
}

\newcommand{\YR@nameblock}{%
  {\TitleFont\fontsize{32pt}{32pt}\selectfont \scshape{\YR@name}}%
  \YR@ifempty{\YR@position}{}{%
    \hspace{1em}{\TitleFont \scshape{\YR@position}}%
  }%
}

\newcommand{\YR@contactblock}{%
  {\TitleFont
   \begin{tabular}[b]{@{}r@{}}
     \YR@ifempty{\YR@phone}{}{ \YR@phone\\ }%
     \YR@ifempty{\YR@email}{}{ \href{mailto:\YR@email}{\YR@email}\\ }%
     \YR@ifempty{\YR@homepage}{}{ \href{\YR@homepage}{\YR@homepage} }%
   \end{tabular}%
  }%
}

\renewcommand{\maketitle}{%
  \thispagestyle{empty}%
  \begingroup
    \parindent=0pt
    \noindent
    \begin{minipage}[t]{0.7\textwidth}
      \YR@nameblock
    \end{minipage}\hfill
    \begin{minipage}[t]{0.3\textwidth}\raggedleft
      \YR@contactblock
    \end{minipage}\par
    \vspace{0.4\baselineskip}
    \hrule
    \vspace{0.2\baselineskip}
  \endgroup
}

\makeatother

% ====================================================================
% CV sections and environments
% ====================================================================
\makeatletter
% ---- Two-column CV environment ----
\newenvironment{cvtwocolumn}[1][0.18]{%
  \begingroup
  \setlength{\parindent}{0pt}%
  \columnratio{#1}%
  \begin{paracol}{2}%
  % Hack: Add invisible phantom text to initialize column synchronization
  % Use \normalsize to ensure standard font size (can be changed to \tiny, \small, \large, etc.)
  \phantom{\tiny}
}{%
  \end{paracol}%
  \endgroup
}

\newcommand{\YR@leftheading}[1]{%
  {\SectionFont\raggedright\scshape\fontsize{14.5pt}{14.5pt}\selectfont #1\par}%
}

% ---- CV section environment ----
\newenvironment{cvsection}[1]{%
  \par\addvspace{0.1\baselineskip}%
  \switchcolumn[0]*%
  \YR@leftheading{#1}%
  \switchcolumn[1]%
  \par
}{%
  \par\addvspace{0.6\baselineskip}%
}
\makeatother

% ====================================================================
% CV content commands
% ====================================================================

% ---- Generic left-right pair line ----
% Usage: \cvpair{<left>}{<right>}
\newcommand{\cvpair}[2]{%
  \noindent
  \begin{tabularx}{\linewidth}{@{}X >{\raggedleft\arraybackslash}l@{}}
    #1 & #2 \\
  \end{tabularx}%
}

% ---- Tunable lengths ----
\newlength{\cvlabelsep}      \setlength{\cvlabelsep}{0.4em}
\newlength{\cvitemleftmargin}\setlength{\cvitemleftmargin}{1.2em}
\newlength{\cvitemsep}       \setlength{\cvitemsep}{0.12\baselineskip}

% ---- Bullet list ----
\newlist{cvitemize}{itemize}{1}
\setlist[cvitemize]{%
  label=\textbullet,
  leftmargin=\cvitemleftmargin,
  labelsep=\cvlabelsep,
  itemindent=0pt,
  listparindent=0pt,
  rightmargin=0pt,
  parsep=0pt,
  itemsep=\cvitemsep,
  topsep=0.5pt,
  partopsep=0pt,
  % Optional: make more compact by reducing itemsep
  before=\setlength{\emergencystretch}{3em},
  after=\vspace{0.5\baselineskip}  % Add spacing after list
}

% ---- Numbered list ----
\newlist{cvnumlist}{enumerate}{1}
\setlist[cvnumlist]{%
  label=\arabic*.,
  % Key: use widest to automatically reserve space for numbers
  % Adjust based on max number in resume: 10. / 99. / 999.
  widest=10.,
  leftmargin=\cvitemleftmargin,
  labelsep=\cvlabelsep,
  labelwidth=\dimexpr\cvitemleftmargin-\cvlabelsep\relax,
  align=left, % Align left edge of "1." and "10."
  itemindent=0pt,
  listparindent=0pt,
  rightmargin=0pt,
  parsep=0pt,
  itemsep=\cvitemsep,
  topsep=0.5pt,
  partopsep=0pt,
  before=\setlength{\emergencystretch}{3em},%
  after=\vspace{0.5\baselineskip}  % Add spacing after list
}
