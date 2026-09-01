-- =========================================================
-- DDL - Banco de Dados: produtosdb
-- Tabela: produtos
-- =========================================================

CREATE DATABASE IF NOT EXISTS produtosdb;
USE produtosdb;

CREATE TABLE IF NOT EXISTS produtos (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    nome        VARCHAR(100)   NOT NULL,
    descricao   VARCHAR(255),
    preco       DECIMAL(10,2)  NOT NULL,
    quantidade  INT            NOT NULL DEFAULT 0
);
