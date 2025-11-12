# Makefile — uv-based workflow for MkDocs + Reveal.js + DeckTape
# Works on macOS, Linux, and Windows (Git Bash / WSL)

SHELL := /usr/bin/env bash

# ---- Slide/CI config ----
# Use Reveal.js v4 (UMD) to avoid ESM issues with DeckTape.
REVEAL_VERSION ?= 4.6.0
DECKTAPE_IMAGE ?= astefanutti/decktape:latest
SLIDE_SIZE 	 ?= 1920x1080

# Pin Python via uv
UV_PY ?= 3.11

.PHONY: help install install-tools bootstrap slides pdf serve serve_noslides build clean check

help:
	@echo "Targets:"
	@echo " 	install 	 	 - install tools (bootstrap), ensure uv + Python $(UV_PY), install deps"
	@echo " 	install-tools 	 - run cross-platform bootstrap only (Pandoc/Docker + DeckTape pull)"
	@echo " 	slides 	 	 	 - generate Reveal.js HTML slides via Pandoc (vendors Reveal v4 locally)"
	@echo " 	pdf 	 	 	 	 - export slides to PDF via DeckTape (Docker)"
	@echo " 	serve 	 	 	 - run mkdocs serve (builds slides first)"
	@echo " 	serve_noslides 	 - serve without regenerating slides"
	@echo " 	build 	 	 	 - build MkDocs site into ./site (slides+pdf first)"
	@echo " 	clean 	 	 	 - remove build artifacts"
	@echo " 	check 	 	 	 - verify external tools (pandoc, docker)"

# ---- Install tools & Python env (uv) ----
install: install-tools
	@set -e; \
	if ! command -v uv >/dev/null 2>&1; then \
		if command -v curl >/dev/null 2>&1; then \
			echo "Installing uv..."; curl -LsSf https://astral.sh/uv/install.sh | sh; \
		elif command -v wget >/dev/null 2>&1; then \
			echo "Installing uv..."; wget -qO- https://astral.sh/uv/install.sh | sh; \
		else \
			echo "Please install uv manually: https://docs.astral.sh/uv/"; exit 1; \
		fi; \
	fi; \
	export PATH="$$HOME/.local/bin:$$HOME/.cargo/bin:$$PATH"; \
	echo "Ensuring Python $(UV_PY) ..."; uv python install $(UV_PY); \
	echo "Syncing project dependencies into .venv ..."; uv sync; \
	echo "✅ uv environment ready (Python $(UV_PY))"

install-tools: bootstrap
	@echo "✅ Tools check complete."

bootstrap:
	@bash scripts/bootstrap.sh

# ---- Slides / PDF ----
slides:
	@REVEAL_VERSION="$(REVEAL_VERSION)" bash scripts/vendor_reveal.sh
	@# Clean up markdown files from vendor dir to avoid mkdocs --strict warnings
	@find docs/vendor -name "*.md" -type f -delete || true
	@bash scripts/generate_slides.sh

pdf:
	@DECKTAPE_IMAGE="$(DECKTAPE_IMAGE)" SLIDE_SIZE="$(SLIDE_SIZE)" bash scripts/export_pdf.sh

# ---- Local dev ----
serve: slides
	uv run mkdocs serve

serve_noslides:
	uv run mkdocs serve

# ---- CI-like full build ----
build: slides pdf
	uv run mkdocs build --strict

# ---- Housekeeping ----
clean:
	rm -rf site
	rm -f docs/slides/watsonx-agentic-ai.html
	rm -f docs/slides/watsonx-agentic-ai.pdf
	@# Also clean up the vendor directory if you want a full reset
	@# rm -rf docs/vendor

# ---- Diagnostics ----
check:
	@command -v pandoc >/dev/null 2>&1 || (echo 'Missing: pandoc' && exit 1)
	@command -v docker  >/dev/null 2>&1 || (echo 'Missing: docker (for PDF export)' && exit 1)
	@echo "✅ All external tools available"