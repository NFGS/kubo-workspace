#!/bin/bash
# ---------------------------------------------------------------------------
# Clona los 8 repositorios hijos del workspace Kubo (polyrepo, ADR-0002).
#
# El workspace es la puerta de entrada: tras clonarlo, este script trae el
# codigo completo en un solo paso (los hijos no viven dentro del workspace).
#
# Uso:  ./scripts/clonar-todos.sh [organizacion]
#       make clone
# ---------------------------------------------------------------------------
set -euo pipefail

ORG="${1:-NFGS}"
REPOS=(
  kubo-gateway kubo-iam kubo-crm kubo-erp kubo-analytics kubo-web kubo-infra kubo-docs
)

cd "$(dirname "$0")/.."

for r in "${REPOS[@]}"; do
  if [ -d "${r}/.git" ]; then
    echo "[kubo] ${r} ya existe (usa git pull para actualizarlo)"
  else
    git clone "https://github.com/${ORG}/${r}.git" "${r}"
  fi
done

echo "[kubo] workspace completo: 8 repos hijos clonados"
