#!/bin/bash
# Cria o container do BANCO no Azure Container Instances (ACI),
# usando a imagem do ACR e montando o File Share para persistir os dados.
#
#   source azure/00-variaveis.sh
#   bash azure/05-criar-aci-db.sh
set -e

# Recupera as credenciais do ACR (para o ACI poder puxar a imagem)
ACR_USER=$(az acr credential show --name "$ACR_NOME" --query username -o tsv)
ACR_SENHA=$(az acr credential show --name "$ACR_NOME" --query "passwords[0].value" -o tsv)

# Recupera a chave da Storage Account (para montar o File Share)
STORAGE_KEY=$(az storage account keys list \
  --resource-group "$GRUPO_RECURSOS" \
  --account-name "$STORAGE_NOME" \
  --query "[0].value" -o tsv)

az container create \
  --resource-group "$GRUPO_RECURSOS" \
  --name "$ACI_DB_NOME" \
  --image "$IMAGEM_DB" \
  --registry-login-server "${ACR_NOME}.azurecr.io" \
  --registry-username "$ACR_USER" \
  --registry-password "$ACR_SENHA" \
  --os-type Linux \
  --cpu 1 \
  --memory 1.5 \
  --ports 3306 \
  --dns-name-label "$DNS_DB" \
  --environment-variables MYSQL_ROOT_PASSWORD="$SENHA_MYSQL" \
  --azure-file-volume-account-name "$STORAGE_NOME" \
  --azure-file-volume-account-key "$STORAGE_KEY" \
  --azure-file-volume-share-name "$FILE_SHARE" \
  --azure-file-volume-mount-path "/var/lib/mysql"

echo "Aguardando o ACI do banco ficar pronto..."
sleep 20

DB_FQDN=$(az container show \
  --resource-group "$GRUPO_RECURSOS" \
  --name "$ACI_DB_NOME" \
  --query "ipAddress.fqdn" -o tsv)

echo "Banco disponivel em: $DB_FQDN:3306"
echo "Guarde esse endereco, ele sera usado no script 06 (criar o ACI do app)."
