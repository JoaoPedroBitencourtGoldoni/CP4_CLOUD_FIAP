#!/bin/bash
# Cria a Conta de Armazenamento (Storage Account) e o File Share
# que vao guardar os dados do MySQL, para nao perder os dados
# se o container do banco reiniciar.
#
#   source azure/00-variaveis.sh
#   bash azure/04-storage-persistencia.sh
set -e

echo "== 1) Cria a Storage Account =="
az storage account create \
  --name "$STORAGE_NOME" \
  --resource-group "$GRUPO_RECURSOS" \
  --location "$LOCATION" \
  --sku Standard_LRS

echo "== 2) Pega a chave de acesso da Storage Account =="
STORAGE_KEY=$(az storage account keys list \
  --resource-group "$GRUPO_RECURSOS" \
  --account-name "$STORAGE_NOME" \
  --query "[0].value" -o tsv)
export STORAGE_KEY

echo "== 3) Cria o File Share onde o MySQL vai gravar os dados =="
az storage share create \
  --name "$FILE_SHARE" \
  --account-name "$STORAGE_NOME" \
  --account-key "$STORAGE_KEY"

echo "Storage Account '$STORAGE_NOME' e File Share '$FILE_SHARE' criados."
echo "Guarde: a chave fica em \$STORAGE_KEY (foi exportada nesta sessao do terminal)."
