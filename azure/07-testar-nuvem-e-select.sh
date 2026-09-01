#!/bin/bash
# Testa o CRUD completo contra o app rodando no ACI, e depois
# comprova cada operacao com um SELECT direto no banco (tambem no ACI).
# GRAVE A TELA enquanto roda este script para usar no video.
#
#   source azure/00-variaveis.sh
#   bash azure/07-testar-nuvem-e-select.sh
set -e

APP_FQDN=$(az container show \
  --resource-group "$GRUPO_RECURSOS" \
  --name "$ACI_APP_NOME" \
  --query "ipAddress.fqdn" -o tsv)

URL="http://$APP_FQDN:8080/produtos"

echo "=========================================="
echo "1) CREATE (POST) - cria um produto"
echo "=========================================="
curl -s -X POST "$URL" -H "Content-Type: application/json" -d @json-testes/post_produto.json
echo -e "\n"

echo "=========================================="
echo "2) READ (GET) - lista todos os produtos"
echo "=========================================="
curl -s "$URL"
echo -e "\n"

echo "=========================================="
echo "3) UPDATE (PUT) - atualiza o produto id=1"
echo "=========================================="
curl -s -X PUT "$URL/1" -H "Content-Type: application/json" -d @json-testes/put_produto.json
echo -e "\n"

echo "=========================================="
echo "4) DELETE - remove o produto id=1"
echo "=========================================="
curl -s -X DELETE "$URL/1" -w "HTTP status: %{http_code}\n"

echo ""
echo "=========================================="
echo "5) EVIDENCIA NO BANCO: abrindo o MySQL dentro do ACI"
echo "   (comando interativo - digite a senha se solicitado)"
echo "=========================================="
echo "Depois de conectar, rode manualmente estes comandos, um a um,"
echo "e mostre a tela no video (isso e a evidencia do CRUD por SELECT):"
echo ""
echo "   USE produtosdb;"
echo "   SELECT * FROM produtos;              -- depois do POST (deve mostrar o produto)"
echo "   SELECT * FROM produtos WHERE id=1;   -- depois do PUT (dados atualizados)"
echo "   SELECT * FROM produtos WHERE id=1;   -- depois do DELETE (deve vir vazio)"
echo ""

az container exec \
  --resource-group "$GRUPO_RECURSOS" \
  --name "$ACI_DB_NOME" \
  --exec-command "mysql -u root -p"
