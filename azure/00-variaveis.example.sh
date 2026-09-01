export RM="COLOQUE_SUA_SENHA_AQUI"                     
export LOCATION="eastus"
export SENHA_MYSQL="Fiap2026Senha!"

export GRUPO_RECURSOS="rg-${RM}-container"
export ACR_NOME="acr${RM}"                       
export STORAGE_NOME="st${RM}"                    
export FILE_SHARE="mysqldata"

export IMAGEM_DB="${ACR_NOME}.azurecr.io/${RM}-db:v1"
export IMAGEM_APP="${ACR_NOME}.azurecr.io/${RM}-app:v1"

export ACI_DB_NOME="${RM}-db-aci"
export ACI_APP_NOME="${RM}-app-aci"

export DNS_DB="${RM}-db"     
export DNS_APP="${RM}-app"   

echo "Variaveis carregadas para o grupo de recursos: $GRUPO_RECURSOS"