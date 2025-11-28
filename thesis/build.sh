#!/usr/bin/env bash
# Robust thesis build wrapper.
# Usage: ./build.sh [pdf|clean|help]  (run from thesis/ directory)
# - pdf  : build PDF (default)
# - clean: remove LaTeX aux files (latexmk -C)
# - help : show this help

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

show_help() {
	cat <<'EOF'
Usage: build.sh [pdf|clean|help]

Commands:
	pdf    Build the thesis PDF (default). Uses system /usr/bin tools to avoid user/snap wrappers.
	clean  Clean auxiliary files (runs `latexmk -C` when available).
	help   Show this message.

Notes:
	- This script prepends /usr/bin to PATH for the build process only, so it won't mutate your shell config.
	- If /usr/bin/latexmk is missing it will fall back to an explicit pdflatex/bibtex sequence.
EOF
}

if [ "${1-}" = "help" ] || [ "${1-}" = "-h" ]; then
	show_help
	exit 0
fi

# Default command: clean auxiliary files (safe, keeps PDF). Pass 'pdf' to build instead.
CMD="${1-clean}"

# reusable clean function (removes aux files but preserves PDF)
do_clean() {
	if [ -x "/usr/bin/latexmk" ]; then
		/usr/bin/latexmk -c -quiet main.tex || true
		echo "Cleaned auxiliary files (latexmk -c). PDF preserved."
	else
		echo "latexmk not found in /usr/bin; removing common aux files instead."
		rm -f *.aux *.log *.out *.toc *.lot *.lof *.bbl *.blg *.idx *.ilg *.ind *.ist \
					*.fls *.fdb_latexmk *.synctex.gz *.nav *.snm || true
		rm -f */*.aux */*.log || true
		echo "Manual clean finished. PDF preserved."
	fi
}

echo "Thesis build wrapper: command='$CMD'"

# Force system binaries first for the duration of this script to avoid ~/bin/miktex/snap wrappers
export PATH="/usr/bin:$PATH"

echo "Using pdflatex: $(command -v pdflatex || true)" 
echo "Using latexmk:  $(command -v latexmk || true)"

case "$CMD" in
	clean)
		# delegate to reusable clean function
		do_clean
		;;

	pdf)
		# Always clean aux files first (preserve PDF), then build.
		echo "Cleaning auxiliary files before building..."
		do_clean
		# Prefer latexmk if available
		if [ -x "/usr/bin/latexmk" ]; then
			echo "Running /usr/bin/latexmk -pdf -interaction=nonstopmode -f main.tex"
			/usr/bin/latexmk -pdf -interaction=nonstopmode -f main.tex
			echo "latexmk finished. Output: main.pdf"
		else
			echo "latexmk not available; falling back to pdflatex/bibtex sequence."
			# Basic sequence: pdflatex -> bibtex -> pdflatex x2 -> makeindex
			/usr/bin/pdflatex -interaction=nonstopmode -halt-on-error main.tex
			if command -v bibtex >/dev/null 2>&1; then
				bibtex main || true
			fi
			/usr/bin/pdflatex -interaction=nonstopmode -halt-on-error main.tex
			/usr/bin/pdflatex -interaction=nonstopmode -halt-on-error main.tex
			if command -v makeindex >/dev/null 2>&1; then
				makeindex main.idx || true
				makeindex symbols.idx || true
			fi
			echo "Fallback pdflatex sequence finished. Output: main.pdf"
		fi
		;;
	*)
		echo "Unknown command: $CMD"
		show_help
		exit 2
		;;
esac

echo "Done. main.pdf is in: $ROOT_DIR/main.pdf"

