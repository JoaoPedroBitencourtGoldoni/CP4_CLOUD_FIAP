# Produtos API — Conteinerização (Java + MySQL + Azure)

API REST simples de CRUD de **produtos**, feita em **Spring Boot**, com banco **MySQL**,
conteinerizada e publicada no **Azure Container Registry (ACR)** e no
**Azure Container Instances (ACI)**, com persistência em **Storage Account**.

## Estrutura do projeto

```
├── app/                  -> código-fonte Java + Dockerfile do app
├── db/                   -> ddl.sql + Dockerfile do banco
├── json-testes/          -> exemplos de JSON usados no GET/POST/PUT/DELETE
├── azure/                -> scripts numerados de Azure CLI (rodar em ordem)
└── README.md
```

---

## 0. Pré-requisitos (instalar uma vez só)

1. **Git Bash** (Windows) — normalmente já vem com o Git for Windows.
2. **Docker Desktop** — instale e abra; deixe rodando em segundo plano (é ele quem
   executa os comandos `docker build`, `docker run`, `docker push`).
3. **Azure CLI** — instale o pacote `az`. Depois de instalar, feche e abra o Git Bash de
   novo para o comando `az` funcionar.
4. Uma conta no **Azure** com uma assinatura ativa (a da FIAP/Azure for Students, etc).

Para conferir se está tudo certo, no Git Bash rode:
```bash
docker --version
az --version
```
Se os dois comandos responderem com uma versão (e não "comando não encontrado"), está ok.

---

## 1. Baixar o projeto

Depois de subir esta pasta para o repositório do grupo no GitHub, no Git Bash:
```bash
git clone <link-do-repositorio-do-grupo>
cd <pasta-do-repositorio>
```

## 2. Editar a única variável obrigatória

Abra `azure/00-variaveis.sh` e troque:
- `RM` → RM real do representante (ex.: `rm123456`, sempre minúsculo)
- `SENHA_MYSQL` → uma senha forte (não precisa avisar ela em lugar nenhum, ela só existe
  localmente e nas variáveis de ambiente do container)

## 3. Build local das imagens e teste local

No Git Bash, **na raiz do projeto**:
```bash
source azure/00-variaveis.sh
bash azure/02-build-e-testar-local.sh
```
Esse script:
1. Faz `docker build` da imagem do banco (`./db`)
2. Faz `docker build` da imagem do app (`./app`)
3. Sobe os dois containers localmente numa rede Docker
4. Testa com `curl` um GET e um POST

Se aparecer o JSON do produto criado no final, deu tudo certo localmente.

Para ver os dados manualmente também dá pra entrar no MySQL local:
```bash
docker exec -it produtos-db-local mysql -u root -p
# digite a senha que você colocou em SENHA_MYSQL
USE produtosdb;
SELECT * FROM produtos;
```

Depois de testar, pode derrubar os containers locais:
```bash
docker rm -f produtos-app-local produtos-db-local
```

> ❗ **Importante:** a entrega NÃO pode ficar em `localhost`. Esse passo é só para
> confirmar que as imagens funcionam antes de subir pra nuvem — a entrega final,
> o vídeo e os testes têm que ser feitos com os recursos rodando no Azure.

## 4. Login no Azure, criar o grupo de recursos e o ACR

```bash
source azure/00-variaveis.sh
bash azure/01-login-grupo-acr.sh
```
Isso abre o navegador para você logar na sua conta Azure, depois cria:
- o **Resource Group**
- o **Azure Container Registry (ACR)**

## 5. Registrar (push) as imagens no ACR

```bash
source azure/00-variaveis.sh
bash azure/03-push-imagens-acr.sh
```
Esse script faz `az acr login` e depois `docker push` das duas imagens
(`<RM>-db` e `<RM>-app`) para dentro do ACR.

## 6. Criar a Storage Account (persistência do banco)

```bash
source azure/00-variaveis.sh
bash azure/04-storage-persistencia.sh
```
Cria a **Storage Account** e um **File Share** — é nele que o MySQL vai gravar os
dados de verdade, para não perder nada se o container reiniciar.

## 7. Criar o ACI do banco de dados

```bash
source azure/00-variaveis.sh
bash azure/05-criar-aci-db.sh
```
Cria o container do banco no **ACI**, já conectado ao File Share criado no passo
anterior (pasta `/var/lib/mysql` dentro do container aponta pro File Share).

## 8. Criar o ACI da aplicação

```bash
source azure/00-variaveis.sh
bash azure/06-criar-aci-app.sh
```
Cria o container do app no ACI, apontando para o endereço do banco criado no
passo 7 (isso é feito automaticamente pelo script).

## 9. Testar tudo na nuvem + evidência do CRUD por SELECT

```bash
source azure/00-variaveis.sh
bash azure/07-testar-nuvem-e-select.sh
```
Esse script:
1. Faz **POST** (cria produto)
2. Faz **GET** (lista produtos)
3. Faz **PUT** (atualiza produto)
4. Faz **DELETE** (remove produto)
5. Abre uma sessão MySQL **dentro do ACI do banco**, onde você digita manualmente
   os `SELECT` para mostrar, na tela e no vídeo, o dado antes/depois de cada operação.

> 🎥 É exatamente esse passo 9 (rodando na nuvem) que deve aparecer gravado no vídeo,
> junto com os recursos abertos no Portal do Azure (ACR, os dois ACIs e a Storage Account).

## 10. (Opcional) Apagar os recursos depois de gravar o vídeo

```bash
source azure/00-variaveis.sh
bash azure/08-limpar-recursos-opcional.sh
```

---

## Endpoints da API

| Método | Rota             | Descrição              | Body (JSON)                     |
|--------|------------------|-------------------------|----------------------------------|
| GET    | `/produtos`      | Lista todos os produtos | -                                |
| GET    | `/produtos/{id}` | Busca um produto por id | -                                |
| POST   | `/produtos`      | Cria um produto         | `json-testes/post_produto.json`  |
| PUT    | `/produtos/{id}` | Atualiza um produto     | `json-testes/put_produto.json`   |
| DELETE | `/produtos/{id}` | Remove um produto       | -                                |

## Sobre a tabela (DDL)

O script `db/ddl.sql` cria o banco `produtosdb` e a tabela `produtos`:

```sql
CREATE TABLE produtos (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    nome        VARCHAR(100)   NOT NULL,
    descricao   VARCHAR(255),
    preco       DECIMAL(10,2)  NOT NULL,
    quantidade  INT            NOT NULL DEFAULT 0
);
```

## Segurança

- Nenhuma senha ou usuário fica escrito no código-fonte: tudo vem por **variáveis de
  ambiente**, definidas na hora de rodar o container (`docker run -e ...` localmente,
  `az container create --environment-variables / --secure-environment-variables` na nuvem).
- A senha do banco é passada como **secure-environment-variable** no ACI do app, o que
  evita que ela apareça em logs ou no `az container show`.
- O container do **app roda com usuário sem privilégios administrativos** (`appuser`,
  criado no `app/Dockerfile` com `adduser -S appuser`), nunca como root.

## Checklist rápido antes de entregar

- [ ] Troquei `RM000000` pelo RM real em `azure/00-variaveis.sh`
- [ ] Testei localmente (passo 3) e deu certo
- [ ] Rodei os scripts 01 a 07 na nuvem, na ordem
- [ ] Gravei vídeo (mín. 720p, com áudio) mostrando: recursos no Portal Azure → app
      rodando na nuvem → cada operação do CRUD → cada SELECT correspondente no banco
- [ ] Subi este repositório completo no GitHub (código, Dockerfiles, scripts, DDL, JSONs)
- [ ] Criei a folha de rosto em PDF (`<nome_grupo>_container.pdf`) com nomes, RMs,
      link do GitHub e link do vídeo
- [ ] O representante do grupo subiu o PDF no Teams
