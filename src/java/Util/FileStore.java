package Util;

import java.io.*;
import java.nio.file.*;
import java.util.UUID;

/**
 * Gère l'enregistrement des fichiers (uploads + résultats).
 * Ici : stockage dans un dossier "uploads" sous le répertoire temporaire.
 */
public class FileStore {

    private final Path baseDir;

    public FileStore() throws IOException {
        // Dossier de base : temp + "/pdf-office-converter"
        this.baseDir = Paths.get(System.getProperty("java.io.tmpdir"), "pdf-office-converter");
        Files.createDirectories(baseDir);
    }

    public String newId() {
        return UUID.randomUUID().toString();
    }

    public Path getBaseDir() {
        return baseDir;
    }

    public Path save(InputStream in, String id, String filename) throws IOException {
        // On “nettoie” un peu le filename
        String safeName = filename.replaceAll("[^a-zA-Z0-9._-]", "_");
        Path out = baseDir.resolve(id + "_" + safeName);

        try (OutputStream os = Files.newOutputStream(out, StandardOpenOption.CREATE_NEW)) {
            byte[] buf = new byte[8192];
            int r;
            while ((r = in.read(buf)) != -1) os.write(buf, 0, r);
        }
        return out;
    }

    public Path resolveByIdPrefix(String idPrefix) throws IOException {
        // Recherche simple : trouve un fichier qui commence par "id_"
        try (DirectoryStream<Path> stream = Files.newDirectoryStream(baseDir, idPrefix + "_*")) {
            for (Path p : stream) return p;
        }
        return null;
    }
}
