#!/usr/bin/env bash
# Contract tests for the class. Expected failures must fail for the named reason.
set -uo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

OUT="${OUT:-build/tests}"
mkdir -p "$OUT"
fails=0

say() { printf '  %-6s %s\n' "$1" "$2"; }
ok()  { say "ok" "$1"; }
bad() { say "FAIL" "$1"; fails=$((fails+1)); }

run_xelatex() {
  local file=$1
  local base
  base=$(basename "${file%.tex}")
  xelatex -halt-on-error -interaction=nonstopmode \
    -output-directory="$OUT" "$file" >"$OUT/$base.stdout" 2>&1
}

expect_pass() {
  local file=$1
  if run_xelatex "$file"; then
    ok "$file"
  else
    bad "$file (unexpected failure)"
  fi
}

expect_fail() {
  local file=$1
  local message=$2
  local base
  base=$(basename "${file%.tex}")
  if run_xelatex "$file"; then
    bad "$file (unexpected success)"
  elif grep -F "$message" "$OUT/$base.log" >/dev/null 2>&1; then
    ok "$file"
  else
    bad "$file (wrong failure; see $OUT/$base.log)"
  fi
}

expect_pass tests/pass-grammar.tex
expect_pass tests/pass-footer.tex
expect_fail tests/fail-section-outside.tex "cvsection used outside cvtwocolumn"
expect_fail tests/fail-nested-section.tex "cvsection nested inside cvsection"
expect_fail tests/fail-nested-container.tex "cvtwocolumn cannot be nested"
expect_fail tests/fail-pair-in-rail.tex "cvpair is inside cvtwocolumn"
expect_fail tests/fail-gap-in-rail.tex "cvgap is inside cvtwocolumn"
expect_fail tests/fail-contact-outside-row.tex "cvcontact used outside cvcontactrow"
expect_fail tests/fail-empty-contact-row.tex "empty cvcontactrow"
expect_fail tests/fail-nested-contact-row.tex "cvcontactrow cannot be nested"
expect_fail tests/fail-missing-font.tex "Font file not found"
expect_fail tests/fail-missing-name.tex "cvname is required by \\maketitle"
expect_fail tests/fail-footer-without-name.tex "cvname is required by pagefooter=true"

if pdflatex -halt-on-error -interaction=nonstopmode -jobname=fail-pdftex \
  -output-directory="$OUT" tests/pass-grammar.tex \
  >"$OUT/fail-pdftex.stdout" 2>&1; then
  bad "pdfLaTeX is rejected (unexpected success)"
elif grep -F "XeTeX is required" "$OUT/fail-pdftex.log" >/dev/null 2>&1; then
  ok "pdfLaTeX is rejected"
else
  bad "pdfLaTeX is rejected (wrong failure; see $OUT/fail-pdftex.log)"
fi

CHECK_OUT="$OUT/check"
if OUT="$CHECK_OUT" scripts/check.sh tests/pass-commented-placeholder.tex \
  >"$OUT/comment-scan.stdout" 2>&1; then
  ok "placeholder comments are ignored"
else
  bad "placeholder comments are ignored (see $OUT/comment-scan.stdout)"
fi

# Builds cleanly, but make check must reject the hand alignment.
printf '%s\n' '\documentclass[icons=false]{yuan2resume}' '\begin{document}' \
  'Hand-aligned \hfill 2024' '\end{document}' >"$OUT/bypass.tex"
if OUT="$CHECK_OUT" scripts/check.sh "$OUT/bypass.tex" \
  >"$OUT/bypass-scan.stdout" 2>&1; then
  bad "hand alignment fails check (unexpected success)"
elif grep -E '^  FAIL +no hand spacing' "$OUT/bypass-scan.stdout" >/dev/null; then
  ok "hand alignment fails check"
else
  bad "hand alignment fails check (wrong failure; see $OUT/bypass-scan.stdout)"
fi

echo
if [ "$fails" -eq 0 ]; then
  echo "  PASS  class contract"
else
  echo "  $fails contract test(s) failed"
fi
exit $((fails > 0))
