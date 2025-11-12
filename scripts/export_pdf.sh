#!/usr/bin/env bash
# scripts/export_pdf.sh
# Robust DeckTape export for Reveal.js slides (works with vendored Reveal v4)
set -euo pipefail

# ---- Config ----
DECKTAPE_IMAGE="${DECKTAPE_IMAGE:-astefanutti/decktape:latest}"
SLIDE_SIZE="${SLIDE_SIZE:-1920x1080}"

# Extra Chrome args to make file:// rendering reliable inside DeckTape
CHROME_ARGS=(
  --chrome-arg=--allow-file-access-from-files
  --chrome-arg=--disable-web-security
  --chrome-arg=--autoplay-policy=no-user-gesture-required
)

# Resolve repo root (script dir → repo root)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.."; pwd -P)"

# Paths (host)
HTML_REL="docs/slides/watsonx-agentic-ai.html"
PDF_REL="docs/slides/watsonx-agentic-ai.pdf"
HTML_HOST="${ROOT}/${HTML_REL}"
PDF_HOST="${ROOT}/${PDF_REL}"

# ---- Pre-checks ----
if ! command -v docker >/dev/null 2>&1; then
  echo "Error: Docker is not installed or not on PATH. Required for DeckTape export." >&2
  exit 1
fi

if [ ! -f "${HTML_HOST}" ]; then
  echo "Slides HTML not found at ${HTML_HOST}. Run scripts/generate_slides.sh first." >&2
  exit 1
fi

# Ensure the DeckTape image is present
if ! docker image inspect "${DECKTAPE_IMAGE}" >/dev/null 2>&1; then
  echo "Pulling DeckTape image: ${DECKTAPE_IMAGE} ..."
  docker pull "${DECKTAPE_IMAGE}"
fi

# ---- Container mount & in-container paths ----
MOUNT_POINT="/work"
HTML_URL="file://${MOUNT_POINT}/${HTML_REL}?print-pdf"
PDF_PATH="${MOUNT_POINT}/${PDF_REL}"

# Create output directory if missing
mkdir -p "$(dirname "${PDF_HOST}")"

echo "Exporting PDF → ${PDF_HOST}"
docker run --rm -t \
  -v "${ROOT}:${MOUNT_POINT}" \
  "${DECKTAPE_IMAGE}" \
  reveal \
  --size "${SLIDE_SIZE}" \
  --slides 1- \
  --load-pause 1500 \
  "${CHROME_ARGS[@]}" \
  "${HTML_URL}" \
  "${PDF_PATH}"

echo "✅ PDF generated at ${PDF_HOST}"
