#!/usr/bin/env bash
# scripts/generate_slides.sh
# Standards-only route (no vendoring):
# - If pandoc < 2.12 → Reveal v3 CDN (cdnjs 3.9.2) to match old template paths (css/*, js/*).
# - If pandoc >= 2.12 → Reveal v4 CDN (jsDelivr dist/*).
# Also forces full-HD layout so PDF export is true 1920×1080, not shrunken print CSS.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.."; pwd -P)"

SOURCE_MD="${SOURCE_MD:-${ROOT}/docs/watsonx-agentic-ai.md}"
OUT_DIR="${OUT_DIR:-${ROOT}/docs/slides}"
DECK_NAME="${DECK_NAME:-$(basename "${SOURCE_MD%.*}")}"
HTML_OUT="${OUT_DIR}/${DECK_NAME}.html"

command -v pandoc >/dev/null 2>&1 || { echo "Pandoc not found. See https://pandoc.org/installing.html" >&2; exit 1; }

PANDOC_VER="$(pandoc -v | head -n1 | awk '{print $2}')"
ver_ge() { [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]; }

mkdir -p "${OUT_DIR}"

# Prefer --embed-resources when available (pandoc ≥ 3.1); fallback to --self-contained
if pandoc --help | grep -q -- "--embed-resources"; then
  EMBED_FLAG="--embed-resources"
else
  EMBED_FLAG="--self-contained"
fi

REVEAL_THEME="${REVEAL_THEME:-league}"
REVEAL_TRANSITION="${REVEAL_TRANSITION:-slide}"

# Pick CDN based on Pandoc’s template expectations
if ver_ge "${PANDOC_VER}" "2.12"; then
  # Reveal v4 (UMD) — standard modern path (dist/*)
  REVEAL_VERSION="${REVEAL_VERSION:-4.6.0}"
  REVEAL_URL="https://cdn.jsdelivr.net/npm/reveal.js@${REVEAL_VERSION}"
  echo "Using Reveal v4 CDN (${REVEAL_URL}) with Pandoc ${PANDOC_VER}"
else
  # Reveal v3 — matches old Pandoc template paths (css/*, js/*)
  REVEAL_URL="https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.9.2"
  echo "Using Reveal v3 CDN (${REVEAL_URL}) with Pandoc ${PANDOC_VER}"
fi

echo "Generating Reveal.js slides → ${HTML_OUT}"
pandoc \
  --standalone \
  --to=revealjs \
  --slide-level=2 \
  ${EMBED_FLAG} \
  --variable "revealjs-url=${REVEAL_URL}" \
  --variable "theme=${REVEAL_THEME}" \
  --variable "transition=${REVEAL_TRANSITION}" \
  --variable slideNumber=true \
  --variable hash=true \
  -V width=1920 \
  -V height=1080 \
  --metadata=pagetitle:"IBM watsonx & Agentic AI" \
  -o "${HTML_OUT}" \
  "${SOURCE_MD}"

echo "✅ Slides generated at ${HTML_OUT}"
