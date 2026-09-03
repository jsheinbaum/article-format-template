#!/usr/bin/env bash
# Idempotent setup for the Article Format Template (AFT) Quarto extension.
# Installs the toolchain needed to render template.qmd to aft-pdf and aft-html:
#   - Quarto CLI
#   - R plus the knitr/rmarkdown engines and recommended packages (MASS, etc.)
#   - TinyTeX (LaTeX distribution used for PDF output)
set -euo pipefail

QUARTO_VERSION="1.10.18"

log() { printf '\n=== %s ===\n' "$1"; }

log "Installing R and rendering engines (knitr, rmarkdown, recommended packages)"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
  ca-certificates curl \
  r-base-core r-recommended r-cran-knitr r-cran-rmarkdown

log "Installing Quarto CLI ${QUARTO_VERSION}"
if command -v quarto >/dev/null 2>&1 && [ "$(quarto --version 2>/dev/null)" = "${QUARTO_VERSION}" ]; then
  echo "Quarto ${QUARTO_VERSION} already installed."
else
  tmp_deb="$(mktemp --suffix=.deb)"
  curl -fL -o "${tmp_deb}" \
    "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb"
  sudo apt-get install -y "${tmp_deb}"
  rm -f "${tmp_deb}"
fi

log "Installing TinyTeX (LaTeX for PDF output)"
if [ -d "${HOME}/.TinyTeX" ]; then
  echo "TinyTeX already present at ${HOME}/.TinyTeX."
else
  quarto install tinytex --no-prompt
fi

log "Toolchain versions"
quarto --version
R --version | head -1

echo "Environment ready. Render with: quarto render template.qmd --to aft-pdf (or aft-html)"
