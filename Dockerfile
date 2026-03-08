# ------------------------------
# Étape 1 : Construction du WAR (Builder)
# ------------------------------
FROM eclipse-temurin:17-jdk-jammy AS builder

# Installation d'Ant et wget
RUN apt-get update && apt-get install -y ant wget && rm -rf /var/lib/apt/lists/*

# 1. Téléchargement de Tomcat 9 (pour les APIs Servlet/JSP)
ENV TOMCAT_VERSION=9.0.89
RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt && \
    rm apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    ln -s /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat

# 2. TÉLÉCHARGEMENT AUTOMATIQUE de CopyLibs (NetBeans)
# On récupère directement le JAR depuis Maven Central pour éviter l'erreur "File not found"
RUN wget -q -O /tmp/copylibstask.jar https://repo1.maven.org/maven2/org/netbeans/modules/org-netbeans-modules-java-j2seproject-copylibstask/RELEASE220/org-netbeans-modules-java-j2seproject-copylibstask-RELEASE220.jar

WORKDIR /app

# Copie des fichiers de configuration et sources
COPY build.xml .
COPY nbproject ./nbproject
COPY src ./src
COPY web ./web

# IMPORTANT : Assurez-vous que ce dossier 'lib' existe sur votre PC avec vos JARs (POI, PDFBox, etc.)
COPY lib ./lib

# Lancement de la compilation
# On utilise le JAR téléchargé dans /tmp/
RUN ant clean dist \
    -Dj2ee.server.home=/opt/tomcat \
    -Dlibs.CopyLibs.classpath=/tmp/copylibstask.jar

# ------------------------------
# Étape 2 : Image finale (Exécution)
# ------------------------------
FROM tomcat:9-jdk17

# Nettoyage de l'instance Tomcat par défaut
RUN rm -rf /usr/local/tomcat/webapps/*

# Récupération du fichier WAR généré à l'étape précédente
COPY --from=builder /app/dist/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]