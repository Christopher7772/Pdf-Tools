
package model;

/**
 * Représente un fichier stocké côté serveur (upload ou résultat).
 * C’est un “petit modèle” pour transporter les infos.
 */
public class FileRecord {
    private final String id;           // identifiant unique (UUID)
    private final String originalName; // nom d'origine
    private final String storedPath;   // chemin serveur
    private final String mimeType;     // type MIME
    private final long sizeBytes;

    public FileRecord(String id, String originalName, String storedPath, String mimeType, long sizeBytes) {
        this.id = id;
        this.originalName = originalName;
        this.storedPath = storedPath;
        this.mimeType = mimeType;
        this.sizeBytes = sizeBytes;
    }

    public String getId() { return id; }
    public String getOriginalName() { return originalName; }
    public String getStoredPath() { return storedPath; }
    public String getMimeType() { return mimeType; }
    public long getSizeBytes() { return sizeBytes; }
}



