#!/usr/bin/env bash
# scripts/export_pdf.sh
# Robust DeckTape export for Reveal.js slides — production-ready
# - Exports ALL slides by default (SLIDES_RANGE=1-)
# - Uses Reveal plugin (no ?print-pdf), so slides render full-HD (no print shrink)
# - CI-friendly Docker flags + Chromium stability flags
set -euo pipefail

# ---- Config (env-overridable) -----------------------------------------------
DECKTAPE_IMAGE="${DECKTAPE_IMAGE:-astefanutti/decktape:latest}"
SLIDE_SIZE="${SLIDE_SIZE:-1920x1080}"
SLIDES_RANGE="${SLIDES_RANGE:-1-}"   # 1- = all slides (you can pass "2-10" etc.)

# Default CI-friendly docker flags; override via DOCKER_RUN_EXTRA if needed
if [ -z "${DOCKER_RUN_EXTRA:-}" ]; then
  DOCKER_RUN_EXTRA="--shm-size=1g -e HOME=/tmp -u $(id -u):$(id -g)"
fi

# Extra Chrome args to make file:// rendering reliable inside DeckTape/Chromium
CHROME_ARGS=(
  --chrome-arg=--allow-file-access-from-files
  --chrome-arg=--disable-web-security
  --chrome-arg=--autoplay-policy=no-user-gesture-required
  --chrome-arg=--no-sandbox
  --chrome-arg=--disable-setuid-sandbox
  --chrome-arg=--disable-dev-shm-usage
  --chrome-arg=--user-data-dir=/tmp/chrome-user
  --chrome-arg=--crash-dumps-dir=/tmp
)

# ---- Paths -------------------------------------------------------------------
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.."; pwd -P)"
HTML_REL="${HTML_REL:-docs/slides/watsonx-agentic-ai.html}"
PDF_REL="${PDF_REL:-docs/slides/watsonx-agentic-ai.pdf}"

HTML_HOST="${ROOT}/${HTML_REL}"
PDF_HOST="${ROOT}/${PDF_REL}"

# ---- Pre-checks --------------------------------------------------------------
command -v docker >/dev/null 2>&1 || { echo "Docker required"; exit 1; }
[ -f "${HTML_HOST}" ] || { echo "Missing HTML: ${HTML_HOST}. Run scripts/generate_slides.sh first."; exit 1; }

# Ensure the DeckTape image is present
docker image inspect "${DECKTAPE_IMAGE}" >/dev/null 2>&1 || docker pull "${DECKTAPE_IMAGE}"

# Ensure output directory exists
mkdir -p "$(dirname "${PDF_HOST}")"

# ---- Container mount & in-container paths ------------------------------------
MOUNT_POINT="/work"
# IMPORTANT: Use the deck as-is (no ?print-pdf) so the Reveal plugin prints the real slides.
HTML_URL="file://${MOUNT_POINT}/${HTML_REL}"
PDF_PATH="${MOUNT_POINT}/${PDF_REL}"

# ---- Run DeckTape ------------------------------------------------------------
echo "Exporting slides range '${SLIDES_RANGE}' at ${SLIDE_SIZE} → ${PDF_HOST}"
docker run --rm -t \
  ${DOCKER_RUN_EXTRA} \
  -v "${ROOT}:${MOUNT_POINT}" \
  "${DECKTAPE_IMAGE}" \
  reveal \
  --size "${SLIDE_SIZE}" \
  --slides "${SLIDES_RANGE}" \
  --load-pause 1500 \
  "${CHROME_ARGS[@]}" \
  "${HTML_URL}" \
  "${PDF_PATH}"

echo "✅ PDF generated at ${PDF_HOST}"
