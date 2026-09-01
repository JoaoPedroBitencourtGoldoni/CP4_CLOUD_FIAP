# ---------- ETAPA 1: build da aplicacao com Maven ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# ---------- ETAPA 2: imagem final, so com o Java Runtime ----------
FROM eclipse-temurin:17-jre-alpine

# Cria um usuario e grupo SEM privilegios administrativos
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app
COPY --from=build /app/target/produtos-api.jar app.jar

# A partir daqui o container passa a rodar como "appuser", nunca como root
USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
