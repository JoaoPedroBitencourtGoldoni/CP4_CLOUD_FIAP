#!/bin/bash
# OPCIONAL: rode isso so DEPOIS de gravar o video e ter certeza
# que nao precisa mais dos recursos, para evitar cobranca.
# Isso apaga TUDO (ACR, ACIs, Storage) de uma vez.
#
#   source azure/00-variaveis.sh
#   bash azure/08-limpar-recursos-opcional.sh
set -e

read -p "Tem certeza que quer apagar o grupo de recursos '$GRUPO_RECURSOS'? (digite SIM) " CONFIRMA
if [ "$CONFIRMA" = "SIM" ]; then
  az group delete --name "$GRUPO_RECURSOS" --yes --no-wait
  echo "Exclusao iniciada (roda em segundo plano)."
else
  echo "Cancelado."
fi
