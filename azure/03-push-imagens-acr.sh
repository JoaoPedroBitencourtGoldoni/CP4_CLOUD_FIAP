#!/bin/bash
# So rode isso DEPOIS de ter testado tudo localmente (script 02)
# e ter certeza que esta tudo OK.
#
#   source azure/00-variaveis.sh
#   bash azure/03-push-imagens-acr.sh
set -e

echo "== 1) Login no ACR =="
az acr login --name "$ACR_NOME"

echo "== 2) Push da imagem do BANCO =="
docker push "$IMAGEM_DB"

echo "== 3) Push da imagem do APP =="
docker push "$IMAGEM_APP"

echo "== 4) Conferindo o que foi registrado no ACR =="
az acr repository list --name "$ACR_NOME" --output table

echo "Imagens registradas com sucesso no ACR: $ACR_NOME"
