FROM eclipse-temurin:17-jdk-jammy AS builder

# Installation des outils nécessaires
RUN apt-get update && apt-get install -y ant curl wget ca-certificates && rm -rf /var/lib/apt/lists/*

# 1. Configuration Tomcat pour Ant
ENV TOMCAT_VERSION=9.0.89
RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt && \
    ln -s /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
    rm apache-tomcat-${TOMCAT_VERSION}.tar.gz

# 2. Téléchargement CopyLibs (Corrigé avec URL vérifiée)
RUN curl -L -f -o /tmp/copylibstask.jar \
    "https://repo1.maven.org/maven2/org/netbeans/modules/org-netbeans-modules-java-j2seproject-copylibstask/RELEASE120/org-netbeans-modules-java-j2seproject-copylibstask-RELEASE120.jar"

WORKDIR /app

# 3. Copie des fichiers (Optimisation du cache)
COPY lib ./lib
COPY nbproject ./nbproject
COPY build.xml .
COPY src ./src
COPY web ./web

# 4. Compilation
RUN ant clean dist -Dj2ee.server.home=/opt/tomcat -Dlibs.CopyLibs.classpath=/tmp/copylibstask.jar

# --- Étape Finale ---
FROM tomcat:9-jdk17-temurin-jammy
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /app/dist/*.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]