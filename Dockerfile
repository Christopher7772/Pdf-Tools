# ------------------------------
# Étape 1 : Construction du WAR avec Ant et Tomcat
# ------------------------------
FROM eclipse-temurin:17-jdk-jammy AS builder

# Installation d'Ant, wget et autres outils
RUN apt-get update && apt-get install -y ant wget && rm -rf /var/lib/apt/lists/*

# Télécharger et extraire Tomcat 9 (pour les bibliothèques J2EE)
ENV TOMCAT_VERSION=9.0.89
RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt && \
    rm apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    ln -s /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat

# Télécharger le fichier copylibstask.jar (nécessaire pour le build NetBeans)
RUN wget -q -O /tmp/copylibstask.jar https://repo1.maven.org/maven2/org/netbeans/modules/org-netbeans-modules-java-j2seproject-copylibstask/RELEASE220/org-netbeans-modules-java-j2seproject-copylibstask-RELEASE220.jar

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers sources nécessaires au build
COPY build.xml .
COPY nbproject ./nbproject
COPY src ./src
COPY web ./web

# Copier les dépendances externes (JARs) – tu dois créer un dossier "lib" à la racine et y mettre tous les JARs nécessaires (PDFBox, POI, etc.)
COPY lib ./lib

# Lancer le build Ant en pointant vers Tomcat et en fournissant le fichier copylibstask.jar
RUN ant clean dist -Dj2ee.server.home=/opt/tomcat -Dlibs.CopyLibs.classpath=/tmp/copylibstask.jar

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