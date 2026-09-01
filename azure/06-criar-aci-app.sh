#!/bin/bash
# Cria o container do APP no ACI, conectado ao banco criado no script 05.
#
#   source azure/00-variaveis.sh
#   bash azure/06-criar-aci-app.sh
set -e

ACR_USER=$(az acr credential show --name "$ACR_NOME" --query username -o tsv)
ACR_SENHA=$(az acr credential show --name "$ACR_NOME" --query "passwords[0].value" -o tsv)

DB_FQDN=$(az container show \
  --resource-group "$GRUPO_RECURSOS" \
  --name "$ACI_DB_NOME" \
  --query "ipAddress.fqdn" -o tsv)

az container create \
  --resource-group "$GRUPO_RECURSOS" \
  --name "$ACI_APP_NOME" \
  --image "$IMAGEM_APP" \
  --registry-login-server "${ACR_NOME}.azurecr.io" \
  --registry-username "$ACR_USER" \
  --registry-password "$ACR_SENHA" \
  --os-type Linux \
  --cpu 1 \
  --memory 1.5 \
  --ports 8080 \
  --dns-name-label "$DNS_APP" \
  --environment-variables \
      DB_HOST="$DB_FQDN" \
      DB_PORT=3306 \
      DB_NAME=produtosdb \
      DB_USER=root \
  --secure-environment-variables \
      DB_PASSWORD="$SENHA_MYSQL"

echo "Aguardando o ACI do app ficar pronto..."
sleep 20

APP_FQDN=$(az container show \
  --resource-group "$GRUPO_RECURSOS" \
  --name "$ACI_APP_NOME" \
  --query "ipAddress.fqdn" -o tsv)

echo "App disponivel em: http://$APP_FQDN:8080/produtos"
