#!/bin/bash
# Faz o BUILD LOCAL das duas imagens e testa tudo na sua maquina
# antes de mandar pra nuvem. Rode a partir da RAIZ do projeto.
#
#   source azure/00-variaveis.sh
#   bash azure/02-build-e-testar-local.sh
set -e

echo "== 1) Build da imagem do BANCO =="
docker build -t "$IMAGEM_DB" ./db

echo "== 2) Build da imagem do APP =="
docker build -t "$IMAGEM_APP" ./app

echo "== 3) Cria uma rede Docker para o app enxergar o banco pelo nome =="
docker network create rede-produtos 2>/dev/null || true

echo "== 4) Sobe o banco localmente =="
docker rm -f produtos-db-local 2>/dev/null || true
docker run -d \
  --name produtos-db-local \
  --network rede-produtos \
  -e MYSQL_ROOT_PASSWORD="$SENHA_MYSQL" \
  -p 3306:3306 \
  "$IMAGEM_DB"

echo "Aguardando o MySQL iniciar..."
sleep 25

echo "== 5) Sobe o app localmente, apontando para o banco acima =="
docker rm -f produtos-app-local 2>/dev/null || true
docker run -d \
  --name produtos-app-local \
  --network rede-produtos \
  -e DB_HOST=produtos-db-local \
  -e DB_PORT=3306 \
  -e DB_NAME=produtosdb \
  -e DB_USER=root \
  -e DB_PASSWORD="$SENHA_MYSQL" \
  -p 8090:8080 \
  "$IMAGEM_APP"

echo "Aguardando o app iniciar..."
sleep 15

echo "== 6) Teste rapido: listar produtos (deve retornar [] ) =="
curl -s http://localhost:8090/produtos
echo ""

echo "== 7) Teste rapido: criar um produto (POST) =="
curl -s -X POST http://localhost:8090/produtos \
  -H "Content-Type: application/json" \
  -d @json-testes/post_produto.json
echo ""

echo "Se voce viu o JSON do produto criado acima, o teste local funcionou!"
echo "Para ver os logs: docker logs produtos-app-local"
echo "Para parar tudo:  docker rm -f produtos-app-local produtos-db-local"
