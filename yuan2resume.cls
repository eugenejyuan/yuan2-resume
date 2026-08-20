\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{yuan2resume}[2026/08/20 v0.4.0 Yuan2Resume class]

\RequirePackage{iftex}
\RequireXeTeX
\RequirePackage{kvoptions}
\SetupKeyvalOptions{
  family=YR,
  prefix=YR@,
  setkeys=\kvsetkeys
}

\DeclareStringOption[commercial]{fontset}
\DeclareBoolOption[false]{pagefooter}
\DeclareBoolOption[true]{icons}

\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessKeyvalOptions*

\LoadClass[11pt]{article}
\RequirePackage[margin=0.7in]{geometry}

\linespread{1.15}

\RequirePackage{paracol}
\RequirePackage{tabularx}
\RequirePackage{enumitem}
\RequirePackage{fontspec}
\RequirePackage[hidelinks,pdfpagelabels=false]{hyperref}

% ====================================================================
% Font configuration
% ====================================================================

% Font-set files use normal fontspec declarations. Requiring the upright file
% here turns a missing licensed font into an immediate, named error.
\newcommand{\cvrequirefont}[1]{%
  \IfFileExists{#1}{}{%
    \ClassError{yuan2resume}{Font file not found: #1}{%
      Run make fonts or install the selected font set.%
    }%
  }%
}

\newcommand{\YR@fontconfig}{configs/fonts-\YR@fontset.tex}
\IfFileExists{\YR@fontconfig}{%
  \input{\YR@fontconfig}%
}{%
  \ClassError{yuan2resume}{Font config file '\YR@fontconfig' not found}{%
    Check the fontset option or add configs/fonts-\YR@fontset.tex.%
  }%
}

% ====================================================================
% Title and contact information
% ====================================================================
\def\YR@name{}
\def\YR@position{}

% Rows are stored verbatim and rendered by \maketitle in declaration order.
\def\YR@contacts{}

% \cvname is required by the two places that print it, and each checks its own
% precondition. Unguarded, a missing name degrades silently: the header sets an
% empty line above the rule, and the page footer reads " . 1/2".
\newcommand{\YR@requirename}[1]{%
  \ifx\YR@name\@empty
    \ClassError{yuan2resume}{cvname is required by #1}{%
      Put \string\cvname{<your name>} in the preamble, before
      \string\begin{document}.%
    }%
  \fi
}

\ifYR@pagefooter
  \RequirePackage{lastpage}
\fi

% Page style: "Name · 2/3"
\def\ps@YRPageFooter{%
  \let\@oddhead\@empty
  \let\@evenhead\@empty
  \def\@oddfoot{%
    \hfil\YR@name\ \textperiodcentered\ \thepage/\pageref{LastPage}\hfil
  }%
  \let\@evenfoot\@oddfoot
}

\newcommand{\YR@apply@pagestyle}{%
  \ifYR@pagefooter
    \pagestyle{YRPageFooter}\thispagestyle{YRPageFooter}%
  \else
    \pagestyle{empty}\thispagestyle{empty}%
  \fi
}

\AtBeginDocument{%
  \ifYR@pagefooter\YR@requirename{pagefooter=true}\fi
  \YR@apply@pagestyle
}

% ====================================================================
% Contact icons
% ====================================================================
% Content names semantic icon slots, never fontawesome glyphs.
\ifYR@icons
  \IfFileExists{fontawesome5.sty}{%
    \RequirePackage{fontawesome5}%
  }{%
    \ClassWarning{yuan2resume}{%
      Package fontawesome5 not found -- contact icons will be omitted.^^J%
      Install it (TeX Live: tlmgr install fontawesome5), or pass
      icons=false to silence this%
    }%
    \YR@iconsfalse
  }
\fi

% The fontawesome command set varies by release. Missing glyphs become named
% warnings here instead of undefined commands much later in \maketitle.
\newcommand{\YR@iconslot}[2]{%
  \ifYR@icons
    \ifcsname #2\endcsname
      \expandafter\newcommand\csname #1\endcsname{\csname #2\endcsname}%
    \else
      \ClassWarning{yuan2resume}{%
        Installed fontawesome5 has no \@backslashchar#2, so
        \@backslashchar#1 will be blank. Rebind it in your preamble:
        \string\renewcommand\@backslashchar#1{\@backslashchar faSomethingElse}%
      }%
      \expandafter\newcommand\csname #1\endcsname{}%
    \fi
  \else
    \expandafter\newcommand\csname #1\endcsname{}%
  \fi
}

\YR@iconslot{cvIconPhone}{faPhone}
\YR@iconslot{cvIconEmail}{faEnvelope}
\YR@iconslot{cvIconSite}{faGlobe}
\YR@iconslot{cvIconScholar}{faGraduationCap}
\YR@iconslot{cvIconGitHub}{faGithub}
\YR@iconslot{cvIconLinkedIn}{faLinkedin}
\YR@iconslot{cvIconLocation}{faMapMarker}

\newlength{\cviconsep}   \setlength{\cviconsep}{0.35em}
\newlength{\cvheadsep}   \setlength{\cvheadsep}{1.5em}
\newlength{\cvcontactsep}\setlength{\cvcontactsep}{1.2em}

\newcommand{\YR@icon}[1]{%
  \ifYR@icons
    \expandafter\ifx\expandafter\relax\detokenize{#1}\relax\else
      {#1}\hspace{\cviconsep}%
    \fi
  \fi
}

\newcommand{\cvname}[1]{\gdef\YR@name{#1}}
\newcommand{\cvposition}[1]{\gdef\YR@position{#1}}

% Contact items are valid only inside an explicit row. Delaying row rendering
% until \maketitle avoids a global three-state item/row accumulator.
\newif\ifYR@incontactrow
\newif\ifYR@firstcontact

\newcommand{\YR@rendercontactrow}[1]{%
  \begingroup
  \YR@incontactrowtrue
  \YR@firstcontacttrue
  #1%
  \ifYR@firstcontact
    \ClassError{yuan2resume}{empty cvcontactrow}{%
      Put at least one \string\cvcontact, \string\cvemail, or
      \string\cvlink inside the row.%
    }%
  \fi
  \endgroup
}

\newcommand{\cvcontactrow}[1]{%
  \ifYR@incontactrow
    \ClassError{yuan2resume}{cvcontactrow cannot be nested}{%
      Contact rows are siblings; remove the inner \string\cvcontactrow.%
    }%
  \else
    \g@addto@macro\YR@contacts{\YR@rendercontactrow{#1}\\}%
  \fi
}

\NewDocumentCommand{\cvcontact}{O{} m}{%
  \ifYR@incontactrow
    \ifYR@firstcontact
      \YR@firstcontactfalse
    \else
      \hspace{\cvcontactsep}%
    \fi
    \YR@icon{#1}#2%
  \else
    \ClassError{yuan2resume}{cvcontact used outside cvcontactrow}{%
      Wrap every contact item in an explicit \string\cvcontactrow.%
    }%
  \fi
}

\NewDocumentCommand{\cvlink}{O{} m m}{\cvcontact[#1]{\href{#2}{#3}}}
\NewDocumentCommand{\cvemail}{O{\cvIconEmail} m}{\cvlink[#1]{mailto:#2}{#2}}

% Both call sites want only the "is set" branch, so that is the whole helper.
\newcommand{\YR@ifset}[2]{\ifx#1\@empty\else #2\fi}

\newcommand{\YR@nameblock}{%
  {\TitleFont\fontsize{32pt}{32pt}\selectfont \scshape{\YR@name}}%
  \YR@ifset{\YR@position}{%
    \hspace{1em}{\TitleFont \scshape{\YR@position}}%
  }%
}

\newcommand{\YR@contactblock}{%
  \YR@ifset{\YR@contacts}{%
    {\TitleFont\begin{tabular}[b]{@{}r@{}}\YR@contacts\end{tabular}}%
  }%
}

\renewcommand{\maketitle}{%
  \YR@requirename{\string\maketitle}%
  \begingroup
    \parindent=0pt
    % A rigid minimum gap turns an overcrowded header into a detectable
    % Overfull \hbox instead of allowing the two blocks to touch silently.
    \noindent\hbox to \textwidth{%
      \YR@nameblock\hspace{\cvheadsep}\hfil\YR@contactblock
    }\par
    \vspace{0.4\baselineskip}
    \hrule
    \vspace{0.2\baselineskip}
  \endgroup
}


% ====================================================================
% CV sections and environments
% ====================================================================
\newlength{\cvsectiontopsep}     \setlength{\cvsectiontopsep}{0.1\baselineskip}
\newlength{\cvsectionbottomsep}  \setlength{\cvsectionbottomsep}{1.0\baselineskip}
\newlength{\cventrysep}          \setlength{\cventrysep}{0.3\baselineskip}

% Environment grouping restores both flags at \end.
\newif\ifYR@intwocolumn
\newif\ifYR@insection

% Only the dangerous case is rejected: content inside the two-column container
% but outside a section would silently land in the narrow label rail.
\newcommand{\YR@requiresection}[1]{%
  \ifYR@intwocolumn\ifYR@insection\else
    \ClassError{yuan2resume}{%
      #1 is inside cvtwocolumn but outside any cvsection, so it would be
      typeset into the narrow left label rail%
    }{%
      cvsection is what switches to the content column. Move #1 between
      \string\begin{cvsection}{<heading>} and \string\end{cvsection}.%
    }%
  \fi\fi
}

\newenvironment{cvtwocolumn}[1][0.18]{%
  \ifYR@intwocolumn
    \ClassError{yuan2resume}{cvtwocolumn cannot be nested}{%
      One cvtwocolumn wraps the whole resume. Sections go inside it as
      siblings; to indent a sub-unit use the cventry environment instead.%
    }%
  \fi
  \begingroup
  \YR@intwocolumntrue
  \setlength{\parindent}{0pt}%
  \columnratio{#1}%
  \begin{paracol}{2}%
  \null % Initialize paracol before the first synchronized column switch.
}{%
  \end{paracol}%
  \endgroup
}

\newcommand{\YR@leftheading}[1]{%
  {\SectionFont\raggedright\scshape\fontsize{14.5pt}{14.5pt}\selectfont #1\par}%
}

\newenvironment{cvsection}[1]{%
  \ifYR@intwocolumn\else
    \ClassError{yuan2resume}{cvsection used outside cvtwocolumn}{%
      cvsection moves between the two paracol columns, which only exist
      inside cvtwocolumn. Wrap your sections in
      \string\begin{cvtwocolumn} ... \string\end{cvtwocolumn}.%
    }%
  \fi
  \ifYR@insection
    \ClassError{yuan2resume}{cvsection nested inside cvsection}{%
      A nested cvsection writes a second heading into the label rail and
      desynchronises the columns. Sections are siblings; for a sub-unit
      inside one section use the cventry environment.%
    }%
  \fi
  \YR@insectiontrue
  \par\addvspace{\cvsectiontopsep}%
  \switchcolumn[0]*%
  \YR@leftheading{#1}%
  \switchcolumn[1]%
  \par
}{%
  \par\addvspace{\cvsectionbottomsep}%
}

% ====================================================================
% CV content commands
% ====================================================================

\newcommand{\cvpair}[2]{%
  \YR@requiresection{\string\cvpair}%
  \noindent
  \begin{tabularx}{\linewidth}{@{}X >{\raggedleft\arraybackslash}l@{}}
    #1 & #2 \\
  \end{tabularx}%
}

% \addvspace, not \vspace: a list that has just ended already contributed
% \cvitemsep below itself, and \addvspace merges the two into one gap rather
% than stacking it with the sibling gap.
\NewDocumentCommand{\cvgap}{O{1}}{%
  \YR@requiresection{\string\cvgap}%
  \par\addvspace{#1\cventrysep}%
}

% ---- Tunable lengths ----
\newlength{\cvlabelsep}      \setlength{\cvlabelsep}{0.4em}
\newlength{\cvitemleftmargin}\setlength{\cvitemleftmargin}{1.2em}
\newlength{\cvitemsep}       \setlength{\cvitemsep}{0.12\baselineskip}

\newlist{cvitemize}{itemize}{1}
\newlist{cvnumlist}{enumerate}{1}

% Invariant 3 -- both list types share ONE left margin -- holds because the
% shared geometry is declared once here, not because two blocks are kept in
% sync by hand. \@currenvir names the offending list in the guard message.
\setlist[cvitemize,cvnumlist]{%
  leftmargin=\cvitemleftmargin,
  labelsep=\cvlabelsep,
  itemindent=0pt,
  listparindent=0pt,
  rightmargin=0pt,
  parsep=0pt,
  itemsep=\cvitemsep,
  topsep=\cvitemsep,
  partopsep=0pt,
  before=\YR@requiresection{\@currenvir}\setlength{\emergencystretch}{3em},%
}

% ---- What differs: the label, and only the label ----
% \setlist* APPENDS; unstarred \setlist REPLACES everything set before it, which
% would silently discard the shared block above and fall back to LaTeX defaults.
\setlist*[cvitemize]{label=\textbullet}
\setlist*[cvnumlist]{%
  label=\arabic*.,
  % Reserve two digits so item 10 does not move the text edge.
  widest=10.,
  labelwidth=\dimexpr\cvitemleftmargin-\cvlabelsep\relax,
  align=left,
}

% The indent is taken from the LEFT ONLY -- the right edge is untouched -- so a
% \cvpair inside a cventry still lands on the document's single shared right
% margin. The default indent also matches the list text edge.
\newlength{\cventryindent}   \setlength{\cventryindent}{\cvitemleftmargin}

\newenvironment{cventry}[1][\cventryindent]{%
  \YR@requiresection{cventry}%
  \par
  \list{}{%
    \setlength{\leftmargin}{#1}%
    \setlength{\rightmargin}{0pt}%
    \setlength{\labelwidth}{0pt}%
    \setlength{\labelsep}{0pt}%
    \setlength{\topsep}{\cvitemsep}%
    \setlength{\partopsep}{0pt}%
    \setlength{\parsep}{0pt}%
    \setlength{\itemsep}{0pt}%
    \setlength{\listparindent}{0pt}%
  }%
  \item\relax
}{%
  \endlist
}
