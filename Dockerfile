# ------------------------------
# Étape 1 : Construction du WAR avec Ant et Tomcat
# ------------------------------
FROM eclipse-temurin:17-jdk-jammy AS builder

# Installation d'Ant et wget (utile pour télécharger Tomcat)
RUN apt-get update && apt-get install -y ant wget && rm -rf /var/lib/apt/lists/*

# Télécharger et extraire Tomcat 9 (pour les bibliothèques J2EE)
ENV TOMCAT_VERSION=9.0.89
RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt && \
    rm apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    ln -s /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat

# Remplacer le téléchargement distant de copylibstask.jar par une copie locale
# (Évite les erreurs de connexion ou d'URL invalide)
# IMPORTANT : Télécharge le fichier manuellement depuis :
#   https://repo1.maven.org/maven2/org/netbeans/modules/org-netbeans-modules-java-j2seproject-copylibstask/RELEASE220/org-netbeans-modules-java-j2seproject-copylibstask-RELEASE220.jar
#   (si ce lien est mort, prends une autre version : RELEASE210, etc.)
# Place le fichier dans un dossier "tools" à la racine de ton projet, renommé en "copylibstask.jar"
COPY tools/copylibstask.jar /tmp/copylibstask.jar

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers sources du projet
COPY build.xml .
COPY nbproject ./nbproject
COPY src ./src
COPY web ./web

# Copier les dépendances externes (JARs) – PDFBox, POI, etc.
# IMPORTANT : Crée un dossier "lib" à la racine de ton projet (au même niveau que src/, web/, etc.)
#            et copie tous les fichiers JAR utilisés par ton application.
#            Tu peux les trouver dans build/web/WEB-INF/lib/ après une compilation locale dans NetBeans.
COPY lib ./lib

# Lancer le build Ant avec les propriétés nécessaires
RUN ant clean dist -Dj2ee.server.home=/opt/tomcat -Dlibs.CopyLibs.classpath=/tmp/copylibstask.jar

# ------------------------------
# Étape 2 : Image d'exécution avec Tomcat
# ------------------------------
FROM tomcat:9-jdk17

# Supprimer les applications web par défaut
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le WAR généré et le déployer à la racine
COPY --from=builder /app/dist/*.war /usr/local/tomcat/webapps/ROOT.war

# Exposer le port Tomcat
EXPOSE 8080

# Démarrer Tomcat
CMD ["catalina.sh", "run"]