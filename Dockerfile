# ==============================================================================
# ÉTAPE 1 : BUILDER (Compilation)
# ==============================================================================
FROM eclipse-temurin:17-jdk-jammy AS builder

# Documentation et métadonnées
LABEL maintainer="Professional Dev"
LABEL description="Java Web App - Builder Stage"

# Variables pour faciliter les mises à jour
ENV ANT_VERSION=1.10.14
ENV TOMCAT_VERSION=9.0.89
ENV COPYLIBS_VERSION=RELEASE120

# Installation optimisée : Ant, wget et certificats (pour éviter les erreurs SSL)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ant \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 1. Préparation de l'environnement Tomcat pour Ant
RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && tar xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt \
    && ln -s /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat \
    && rm apache-tomcat-${TOMCAT_VERSION}.tar.gz

# 2. Téléchargement du JAR CopyLibs (Version stable corrigée)
RUN wget -q --no-check-certificate -O /tmp/copylibstask.jar \
    https://repo1.maven.org/maven2/org/netbeans/modules/org-netbeans-modules-java-j2seproject-copylibstask/${COPYLIBS_VERSION}/org-netbeans-modules-java-j2seproject-copylibstask-${COPYLIBS_VERSION}.jar

WORKDIR /app

# 3. Optimisation du cache Docker : on copie les dépendances AVANT le code source
# Si vous ne modifiez pas vos JARs, Docker sautera cette étape lors du prochain build
COPY lib/ ./lib/
COPY nbproject/ ./nbproject/
COPY build.xml .

# 4. Copie du code source
COPY src/ ./src/
COPY web/ ./web/

# 5. Compilation
RUN ant clean dist \
    -Dj2ee.server.home=/opt/tomcat \
    -Dlibs.CopyLibs.classpath=/tmp/copylibstask.jar

# ==============================================================================
# ÉTAPE 2 : RUNNER (Exécution)
# ==============================================================================
FROM tomcat:9-jdk17-temurin-jammy

LABEL description="Java Web App - Execution Stage"

WORKDIR /usr/local/tomcat

# Nettoyage pro des applications par défaut
RUN rm -rf webapps/*

# Copie sécurisée du WAR depuis le builder
COPY --from=builder /app/dist/*.war webapps/ROOT.war

# Configuration de l'environnement de production
ENV JAVA_OPTS="-Xms512m -Xmx1024m -Dfile.encoding=UTF-8"

# Optionnel : Ajout d'un Healthcheck pour surveiller l'état de l'app
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/ || exit 1

EXPOSE 8080

CMD ["catalina.sh", "run"]