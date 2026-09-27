#!/usr/bin/env bash
# Definition of done, executable. Exits non-zero if the resume is not shippable.
#
#   scripts/check.sh [file.tex]      default: main.tex
#   PAGES=2 scripts/check.sh         raise the page budget (academic CVs)
#
# To check the same content under another font set, change the fontset option
# in the file itself and run this again -- there is nothing to configure here.
#
# Deliberately has no dependency beyond latexmk: the page count is read out of
# the log, not out of ghostscript, so this runs anywhere the document builds.
set -uo pipefail

TARGET="${1:-main.tex}"
OUT="${OUT:-build}"
PAGES="${PAGES:-1}"
BASE="$(basename "${TARGET%.tex}")"
LOG="$OUT/$BASE.log"
fails=0

say()  { printf '  %-6s %-40s %s\n' "$1" "$2" "${3:-}"; }
ok()   { say "ok"   "$1" "${2:-}"; }
bad()  { say "FAIL" "$1" "${2:-}"; fails=$((fails+1)); }
warn() { say "warn" "$1" "${2:-}"; }

[ -f "$TARGET" ] || { echo "no such file: $TARGET" >&2; exit 2; }
echo "checking $TARGET (page budget: $PAGES)"

# --- 1. it has to build ----------------------------------------------------
if latexmk -xelatex -interaction=nonstopmode -outdir="$OUT" "$TARGET" >/dev/null 2>&1; then
  ok "builds with xelatex"
else
  bad "builds with xelatex" "see $LOG"
fi
[ -f "$LOG" ] || { echo "  FAIL  no log produced; cannot continue"; exit 1; }

count() { grep -c "$1" "$LOG" 2>/dev/null | tr -d ' '; }

# --- 2. alignment ----------------------------------------------------------
# Overfull hbox is a WARNING: the PDF still builds and xelatex still exits 0.
# It is the single most likely defect to ship unnoticed, so it is checked here.
n=$(count 'Overfull \\hbox')
[ "$n" = 0 ] && ok "no overfull hbox" || bad "no overfull hbox" "$n found"

n=$(count 'Underfull \\hbox')
[ "$n" = 0 ] || warn "underfull hbox" "$n found (loose lines; not fatal)"

# --- 3. typography actually loaded ----------------------------------------
n=$(count 'Font file not found')
[ "$n" = 0 ] && ok "all fonts resolved" || bad "all fonts resolved" "$n missing"

# --- 4. the grammar was used correctly ------------------------------------
n=$(count 'Class yuan2resume Error')
[ "$n" = 0 ] && ok "no structural misuse" || bad "no structural misuse" "$n error(s)"

# --- 5. length -------------------------------------------------------------
# xelatex hard-wraps the log at ~79 columns, so "(1 page," can land on the
# next line when the output path is long. Join the log before matching.
pages=$(tr -d '\n' < "$LOG" | sed -n 's/.*Output written on [^(]*(\([0-9][0-9]*\) page.*/\1/p')
if [ -z "$pages" ]; then
  bad "page count <= $PAGES" "could not read page count from log"
elif [ "$pages" -le "$PAGES" ]; then
  ok "page count <= $PAGES" "$pages"
else
  bad "page count <= $PAGES" "$pages -- cut prose, do not shrink spacing"
fi

# --- 6. content never spaces, sizes or aligns by hand ----------------------
# Checkable by SHAPE: each command below has a primitive or a preamble knob that
# does its job (docs/GRAMMAR.md), so none has a legitimate use in a content file
# -- not even \vspace{\cventrysep}, which is what \cvgap is for.
uncommented() { sed 's/^[[:space:]]*%.*//; s/\([^\\]\)%.*/\1/' "$1"; }
bypass='\\(vspace|vskip|bigskip|medskip|smallskip|hspace|hskip|hfill?|leftskip'
bypass="$bypass"'|(sub)*section|newpage|clearpage|pagebreak|footnote|linespread|geometry|newgeometry'
bypass="$bypass"'|fontsize|tiny|scriptsize|footnotesize|small|large|Large|LARGE|huge|Huge)([^A-Za-z]|$)'
bypass="$bypass"'|\\\\\[|\\begin\{(itemize|enumerate|tabular|tabularx|minipage|figure|table)\}'
hits=$(uncommented "$TARGET" | grep -nE "$bypass" | head -5)
if [ -z "$hits" ]; then
  ok "no hand spacing, sizing or alignment"
else
  bad "no hand spacing, sizing or alignment" "use a primitive (docs/GRAMMAR.md):"
  printf '%s\n' "$hits" | sed 's/^/           /'
fi

# --- 7. no placeholder survived -------------------------------------------
# This list mirrors the field placeholders in main.tex; change one there and
# change it here. Skipped for examples/: demonstrations, not deliverables.
case "$TARGET" in
  examples/*) warn "placeholder scan" "skipped (example file)" ;;
  *)
    hits=$(uncommented "$TARGET" | grep -nE 'Your Name|Your Job Title|Your Degree|Employer Name|Earlier Employer|Earlier Title|University Name|Project Name|City, Country|567-8900|example\.com|github\.com/you|citations\?user=XXXX' | head -5)
    if [ -n "$hits" ]; then
      bad "no placeholder text" "still template boilerplate:"
      printf '%s\n' "$hits" | sed 's/^/           /'
    else
      ok "no placeholder text"
    fi ;;
esac

echo
if [ "$fails" -eq 0 ]; then
  echo "  PASS  $TARGET is shippable"
else
  echo "  $fails check(s) failed"
fi
exit $((fails > 0))
