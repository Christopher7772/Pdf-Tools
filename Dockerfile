# On utilise l'image officielle de Tomcat 9
FROM tomcat:9.0-jdk17-openjdk-slim

# On nettoie les dossiers par défaut
RUN rm -rf /usr/local/tomcat/webapps/*

# On copie ton fichier .war déjà compilé
# (Remplace 'MonProjet.war' par le vrai nom de ton fichier dans le dossier dist)
COPY dist/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]