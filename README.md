# Hello MkDocs + Reveal.js

Author once in Markdown, publish as **MkDocs docs**, **Reveal.js slides**, and **PDF**—locally and in CI.

## Quick start

```bash
# 1) Create venv and install deps
make install

# 2) Generate slides from docs/watsonx-agentic-ai.md
make slides

# 3) (Optional) Export PDF (requires Docker)
make pdf

# 4) Serve MkDocs locally (http://127.0.0.1:8000)
make serve
```

Deployed site (via GitHub Pages) will include:
- `/slides/watsonx-agentic-ai.html` (interactive deck)
- `/slides/watsonx-agentic-ai.pdf` (PDF deck)

## Prereqs

- Python 3.9+
- Pandoc (for HTML slide generation) — install via your package manager
- Docker (for DeckTape PDF export) — optional locally; used in CI

## Structure

```text
.
├─ docs/
│  ├─ index.md
│  ├─ watsonx-agentic-ai.md
│  └─ slides/
│     └─ (generated) watsonx-agentic-ai.html / .pdf
├─ scripts/
│  ├─ generate_slides.sh
│  └─ export_pdf.sh
├─ mkdocs.yml
├─ Makefile
└─ .github/workflows/deploy.yml
```

## Notes

- Slides and PDFs are generated into `docs/slides/` so `mkdocs build` will ship them.
- If you change the source Markdown or filenames, update the scripts and `mkdocs.yml` nav accordingly.



Keeping docs and slides in sync is hard. Update a code sample in the docs, forget the deck, and drift happens.
This repository shows how to author **one** Markdown file and publish it as both a **MkDocs** page and a **Reveal.js** deck (+ PDF).

---

## Why a single source?
- **Consistency**: one edit propagates everywhere.
- **Efficiency**: no duplicate maintenance.
- **Versioning**: one file, one history.

## Tooling
- Markdown → authoring
- Pandoc → Markdown → Reveal.js HTML
- Reveal.js → modern HTML slides
- MkDocs (+ Material) → static documentation site
- DeckTape (Docker) → PDF export of slides
- GitHub Actions → build & deploy

## How slides are split
Pandoc uses headings; with `--slide-level=2`, every `##` becomes a **new slide**, and `###` creates a **vertical sub-slide**.

Use header attributes for transitions/backgrounds, e.g.:

```markdown
## Title {data-transition="fade" data-background-color="#0f172a"}
```

Notes for speakers can go in fenced blocks:

```markdown
::: notes
Presenter-only notes here.
:::
```

## Generate slides (HTML)
Run:

```bash
bash scripts/generate_slides.sh
```

This writes `docs/slides/watsonx-agentic-ai.html`. We point Pandoc at the Reveal.js CDN so assets resolve in CI.

## Export to PDF
Use DeckTape (Docker required):

```bash
bash scripts/export_pdf.sh
```

The script loads `file:///…/docs/slides/watsonx-agentic-ai.html?print-pdf` so Reveal's print stylesheet applies.

## MkDocs navigation
`mkdocs.yml` links to both the HTML and PDF under **Slides**. Because artifacts live under `docs/`, `mkdocs build` copies them into `site/` automatically.

## CI workflow
See `.github/workflows/deploy.yml`. It:
1. Generates the HTML slides via Pandoc.
2. Generates the PDF via DeckTape.
3. Builds the MkDocs site.
4. Publishes to GitHub Pages.

## Troubleshooting
- Blank PDFs? Ensure `?print-pdf` is in the URL DeckTape opens.
- Assets fail in CI? Use the Reveal.js CDN as configured.
- MkDocs missing slides? Confirm artifacts exist in `docs/slides/` before `mkdocs build`.

## License
Apache 2.0 and reuse.
