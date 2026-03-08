# ------------------------------
# Étape 1 : Construction du JAR
# ------------------------------
FROM maven:3.8.7-eclipse-temurin-17 AS builder

# Dossier de travail
WORKDIR /app

# 1. Copie uniquement le pom.xml pour profiter du cache Docker
COPY pom.xml .
# Téléchargement des dépendances (sans compiler)
RUN mvn dependency:go-offline -B

# 2. Copie du code source
COPY src ./src

# 3. Compilation et packaging (sans les tests pour accélérer)
RUN mvn clean package -DskipTests

# ------------------------------
# Étape 2 : Image d'exécution légère
# ------------------------------
FROM eclipse-temurin:17-jre-jammy

# Création d'un utilisateur non‑root pour la sécurité
RUN addgroup --system --gid 1001 appuser && \
    adduser --system --uid 1001 --gid 1001 appuser
USER appuser

# Dossier de travail
WORKDIR /app

# Copie du JAR depuis l'étape précédente
COPY --from=builder /app/target/*.jar app.jar

# Exposition du port par défaut de Spring Boot
EXPOSE 8080

# Commande de démarrage
ENTRYPOINT ["java", "-jar", "app.jar"]