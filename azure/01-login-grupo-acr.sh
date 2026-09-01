#!/bin/bash
# Rode assim (depois de ter dado "source azure/00-variaveis.sh"):
#   bash azure/01-login-grupo-acr.sh
set -e

# 1) Login no Azure (abre o navegador para voce entrar com sua conta)
az login

# 2) Cria o grupo de recursos onde tudo vai morar
az group create \
  --name "$GRUPO_RECURSOS" \
  --location "$LOCATION"

# 3) Cria o Azure Container Registry (ACR) - onde as imagens Docker vao ficar
az acr create \
  --resource-group "$GRUPO_RECURSOS" \
  --name "$ACR_NOME" \
  --sku Basic \
  --admin-enabled true

echo "Grupo de recursos e ACR criados com sucesso."
