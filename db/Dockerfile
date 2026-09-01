# Imagem customizada do banco: MySQL oficial + nossa DDL
# ja embutida, para a tabela "produtos" ser criada automaticamente
# na primeira vez que o container subir.
FROM mysql:8.0

COPY ddl.sql /docker-entrypoint-initdb.d/ddl.sql

EXPOSE 3306
