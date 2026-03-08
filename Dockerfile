# ------------------------------
# Étape 1 : Construction du WAR avec Ant
# ------------------------------
FROM eclipse-temurin:17-jdk-jammy AS builder

# Installation d'Ant (outil de build)
RUN apt-get update && apt-get install -y ant && rm -rf /var/lib/apt/lists/*

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers sources nécessaires au build
COPY build.xml .
COPY nbproject ./nbproject
COPY src ./src
COPY web ./web

# IMPORTANT : Si ton projet a des dépendances externes (JARs) dans un dossier lib/, décommente la ligne suivante :
# COPY lib ./lib

# Lancer le build Ant (cible "dist" générant le WAR dans dist/)
RUN ant clean dist

# ------------------------------
# Étape 2 : Image d'exécution avec Tomcat
# ------------------------------
FROM tomcat:9-jdk17

# Supprimer les applications web par défaut de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le WAR depuis l'étape de build et le déposer en tant qu'application racine (ROOT.war)
COPY --from=builder /app/dist/*.war /usr/local/tomcat/webapps/ROOT.war

# Exposer le port par défaut de Tomcat
EXPOSE 8080

# Démarrer Tomcat
CMD ["catalina.sh", "run"]