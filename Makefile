# Makefile — Simple workflow for MkDocs + Reveal.js + DeckTape
# Works on Windows (PowerShell, Git Bash), macOS, and Linux

SHELL := /usr/bin/env bash

# ========== Configuration ==========
DECKTAPE_IMAGE ?= astefanutti/decktape:latest
SLIDE_SIZE     ?= 1920x1080
UV_PY          ?= 3.11

# PDF Export (FIXED: Explicit range + extended timing)
PDF_SLIDES     ?= 1-100
LOAD_PAUSE     ?= 8000
PAUSE          ?= 2000

# Slide Theming (FIXED: Use valid Pandoc highlight styles)
REVEAL_THEME      ?= black
REVEAL_TRANSITION ?= convex
HIGHLIGHT_STYLE   ?= zenburn

# MathJax Support (set to "yes" to enable LaTeX math, "no" to disable)
ENABLE_MATH       ?= yes

.PHONY: help install install-tools bootstrap \
        slides slides-dark slides-light slides-tech slides-creative \
        pdf pdf-debug \
        serve serve-noslides \
        build build-quick \
        clean clean-all \
        check info

# ========== Help ==========
help:
	@echo "================================================================"
	@echo "  MkDocs + Reveal.js + PDF - Enhanced Workflow"
	@echo "================================================================"
	@echo ""
	@echo "QUICK START:"
	@echo "  make install         - Install all dependencies"
	@echo "  make slides          - Generate HTML slides (black theme)"
	@echo "  make pdf             - Export to PDF (ALL slides, fixed)"
	@echo "  make serve           - Preview site locally"
	@echo ""
	@echo "SLIDE THEMES:"
	@echo "  make slides-dark     - Professional dark theme (recommended)"
	@echo "  make slides-light    - Clean light theme"
	@echo "  make slides-tech     - Technical dark theme"
	@echo "  make slides-creative - Vibrant sky theme"
	@echo ""
	@echo "PDF EXPORT:"
	@echo "  make pdf             - Standard export (8s load, 2s/slide)"
	@echo "  make pdf-debug       - Export with screenshots for debugging"
	@echo ""
	@echo "DEVELOPMENT:"
	@echo "  make serve           - Build slides + serve (auto-reload)"
	@echo "  make serve-noslides  - Serve without rebuilding slides"
	@echo ""
	@echo "BUILD:"
	@echo "  make build           - Full build (slides + PDF + docs)"
	@echo "  make build-quick     - Quick build (skip PDF)"
	@echo ""
	@echo "CLEANUP:"
	@echo "  make clean           - Remove generated files"
	@echo "  make clean-all       - Remove everything (including venv)"
	@echo ""
	@echo "DIAGNOSTICS:"
	@echo "  make check           - Verify external tools"
	@echo "  make info            - Show current configuration"
	@echo ""
	@echo "CONFIGURATION:"
	@echo "  PDF_SLIDES=$(PDF_SLIDES)   - Slide range for PDF export"
	@echo "  LOAD_PAUSE=$(LOAD_PAUSE)ms - Initial page load time"
	@echo "  PAUSE=$(PAUSE)ms       - Pause between slides"
	@echo "  ENABLE_MATH=$(ENABLE_MATH)     - MathJax support (yes/no)"
	@echo "================================================================"

# ========== Installation ==========
install: install-tools
	@echo "================================================================"
	@echo "Installing Python environment with uv..."
	@echo "================================================================"
	@set -e; \
	if ! command -v uv >/dev/null 2>&1; then \
		if command -v curl >/dev/null 2>&1; then \
			echo "Installing uv..."; \
			curl -LsSf https://astral.sh/uv/install.sh | sh; \
		elif command -v wget >/dev/null 2>&1; then \
			echo "Installing uv..."; \
			wget -qO- https://astral.sh/uv/install.sh | sh; \
		else \
			echo "ERROR: curl or wget required"; \
			echo "Install manually from: https://docs.astral.sh/uv/"; \
			exit 1; \
		fi; \
	fi; \
	export PATH="$$HOME/.local/bin:$$HOME/.cargo/bin:$$PATH"; \
	echo "Ensuring Python $(UV_PY)..."; \
	uv python install $(UV_PY); \
	echo "Syncing dependencies..."; \
	uv sync; \
	echo "================================================================"; \
	echo "Installation complete!"; \
	echo "================================================================"

install-tools: bootstrap
	@echo "[OK] External tools check complete"

bootstrap:
	@bash scripts/bootstrap.sh

# ========== Slide Generation ==========
slides:
	@echo "Generating slides: $(REVEAL_THEME) theme, $(REVEAL_TRANSITION) transition"
	@REVEAL_THEME="$(REVEAL_THEME)" \
	 REVEAL_TRANSITION="$(REVEAL_TRANSITION)" \
	 HIGHLIGHT_STYLE="$(HIGHLIGHT_STYLE)" \
	 ENABLE_MATH="$(ENABLE_MATH)" \
	 bash scripts/generate_slides.sh

slides-dark:
	@echo "Generating DARK theme slides..."
	@REVEAL_THEME=black \
	 REVEAL_TRANSITION=convex \
	 HIGHLIGHT_STYLE=zenburn \
	 ENABLE_MATH="$(ENABLE_MATH)" \
	 bash scripts/generate_slides.sh
	@echo "[OK] Dark theme slides generated!"

slides-light:
	@echo "Generating LIGHT theme slides..."
	@REVEAL_THEME=white \
	 REVEAL_TRANSITION=fade \
	 HIGHLIGHT_STYLE=pygments \
	 ENABLE_MATH="$(ENABLE_MATH)" \
	 bash scripts/generate_slides.sh
	@echo "[OK] Light theme slides generated!"

slides-tech:
	@echo "Generating TECHNICAL theme slides..."
	@REVEAL_THEME=night \
	 REVEAL_TRANSITION=slide \
	 HIGHLIGHT_STYLE=zenburn \
	 ENABLE_MATH="$(ENABLE_MATH)" \
	 bash scripts/generate_slides.sh
	@echo "[OK] Technical theme slides generated!"

slides-creative:
	@echo "Generating CREATIVE theme slides..."
	@REVEAL_THEME=sky \
	 REVEAL_TRANSITION=zoom \
	 HIGHLIGHT_STYLE=tango \
	 ENABLE_MATH="$(ENABLE_MATH)" \
	 bash scripts/generate_slides.sh
	@echo "[OK] Creative theme slides generated!"

# ========== PDF Export (FIXED!) ==========
pdf:
	@echo "================================================================"
	@echo "Exporting to PDF with FIXED timing (ALL slides)"
	@echo "================================================================"
	@echo "Configuration:"
	@echo "  Slides range:  $(PDF_SLIDES)"
	@echo "  Size:          $(SLIDE_SIZE)"
	@echo "  Load pause:    $(LOAD_PAUSE)ms (extended for full HD)"
	@echo "  Slide pause:   $(PAUSE)ms (allows navigation)"
	@echo "================================================================"
	@DECKTAPE_IMAGE="$(DECKTAPE_IMAGE)" \
	 SLIDE_SIZE="$(SLIDE_SIZE)" \
	 SLIDES_RANGE="$(PDF_SLIDES)" \
	 LOAD_PAUSE="$(LOAD_PAUSE)" \
	 PAUSE="$(PAUSE)" \
	 bash scripts/export_pdf.sh

pdf-debug:
	@echo "Generating PDF with debug screenshots..."
	@mkdir -p debug-slides
	@docker run --rm -t \
	  --shm-size=2g \
	  -e HOME=/tmp \
	  -u $$(id -u):$$(id -g) \
	  -v "$$PWD":/work \
	  astefanutti/decktape \
	  reveal \
	  --screenshots \
	  --screenshots-directory /work/debug-slides \
	  --size $(SLIDE_SIZE) \
	  --slides $(PDF_SLIDES) \
	  --load-pause $(LOAD_PAUSE) \
	  --pause $(PAUSE) \
	  "file:///work/docs/slides/watsonx-agentic-ai.html" \
	  "/work/docs/slides/watsonx-agentic-ai-debug.pdf"
	@echo "[OK] Debug PDF + screenshots in debug-slides/"

# ========== Development Server ==========
serve: slides
	@echo "Starting MkDocs development server..."
	@echo "URL: http://127.0.0.1:8000"
	@echo "Press Ctrl+C to stop"
	@uv run mkdocs serve

serve-noslides:
	@echo "Starting MkDocs (without rebuilding slides)..."
	@uv run mkdocs serve

# ========== Build ==========
build: slides pdf
	@echo "================================================================"
	@echo "Building complete site..."
	@echo "================================================================"
	@uv run mkdocs build --strict
	@echo "[OK] Site built successfully in ./site/"

build-quick: slides
	@echo "Quick build (skipping PDF)..."
	@uv run mkdocs build --strict
	@echo "[OK] Quick build complete"

# ========== Cleanup ==========
clean:
	@echo "Cleaning generated files..."
	@rm -rf site .cache
	@rm -f docs/slides/watsonx-agentic-ai.html
	@rm -f docs/slides/watsonx-agentic-ai.pdf
	@rm -f docs/slides/watsonx-agentic-ai-debug.pdf
	@rm -rf debug-slides
	@echo "[OK] Cleaned"

clean-all: clean
	@echo "Removing Python virtual environment..."
	@rm -rf .venv
	@echo "[OK] Deep clean complete"

# ========== Diagnostics ==========
check:
	@echo "================================================================"
	@echo "Checking external dependencies..."
	@echo "================================================================"
	@command -v pandoc >/dev/null 2>&1 && echo "[OK] Pandoc: $$(pandoc --version | head -n1)" || echo "[!!] Pandoc: NOT FOUND"
	@command -v docker >/dev/null 2>&1 && echo "[OK] Docker: $$(docker --version)" || echo "[!!] Docker: NOT FOUND"
	@command -v uv >/dev/null 2>&1 && echo "[OK] uv: $$(uv --version)" || echo "[  ] uv: NOT FOUND (will be installed)"
	@command -v python3 >/dev/null 2>&1 && echo "[OK] Python: $$(python3 --version)" || echo "[!!] Python: NOT FOUND"
	@echo "================================================================"
	@if command -v pandoc >/dev/null 2>&1 && command -v docker >/dev/null 2>&1; then \
		echo "[OK] All required tools are available"; \
	else \
		echo "[!!] Some required tools are missing"; \
		exit 1; \
	fi

info:
	@echo "================================================================"
	@echo "Current Configuration"
	@echo "================================================================"
	@echo ""
	@echo "Slide Generation:"
	@echo "  Theme:         $(REVEAL_THEME)"
	@echo "  Transition:    $(REVEAL_TRANSITION)"
	@echo "  Code Style:    $(HIGHLIGHT_STYLE)"
	@echo "  Math Support:  $(ENABLE_MATH)"
	@echo ""
	@echo "PDF Export:"
	@echo "  Size:          $(SLIDE_SIZE)"
	@echo "  Slide Range:   $(PDF_SLIDES)"
	@echo "  Load Pause:    $(LOAD_PAUSE)ms"
	@echo "  Slide Pause:   $(PAUSE)ms"
	@echo ""
	@echo "Python:"
	@echo "  Target:        $(UV_PY)"
	@if [ -d .venv ]; then \
		echo "  Virtual Env:   [OK] Active"; \
	else \
		echo "  Virtual Env:   [  ] Not created (run 'make install')"; \
	fi
	@echo ""
	@echo "Files:"
	@if [ -f docs/slides/watsonx-agentic-ai.html ]; then \
		echo "  HTML Slides:   [OK] Generated"; \
	else \
		echo "  HTML Slides:   [  ] Not generated (run 'make slides')"; \
	fi
	@if [ -f docs/slides/watsonx-agentic-ai.pdf ]; then \
		echo "  PDF Slides:    [OK] Generated"; \
	else \
		echo "  PDF Slides:    [  ] Not generated (run 'make pdf')"; \
	fi
	@echo "================================================================"

.DEFAULT_GOAL := help