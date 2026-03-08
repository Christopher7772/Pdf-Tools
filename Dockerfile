FROM tomcat:9-jdk17-temurin-jammy

# 1. On nettoie Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# 2. On copie TOUT ton projet dans le dossier webapps de Tomcat
# On utilise le dossier 'web' qui contient tes pages JSP et tes libs
COPY web/ /usr/local/tomcat/webapps/ROOT/

# 3. Si tu as des JARs (PDFBox, POI) dans un dossier lib, on les ajoute
COPY lib/*.jar /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/

EXPOSE 8080
CMD ["catalina.sh", "run"]
