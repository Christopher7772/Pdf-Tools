package Util;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Génère des liens de partage.
 * Important : WhatsApp/Telegram ne “prennent” pas ton fichier directement.
 * Ils partagent surtout un TEXTE ou un LIEN (ex: lien de téléchargement).
 */
public class ShareLinkUtil {

    public static String whatsappShareLink(String downloadUrl) {
        String text = "Télécharger le fichier : " + downloadUrl;
        String encoded = URLEncoder.encode(text, StandardCharsets.UTF_8);
        return "https://wa.me/?text=" + encoded;
    }

    public static String telegramShareLink(String downloadUrl) {
        String text = "Télécharger le fichier : " + downloadUrl;
        String encoded = URLEncoder.encode(text, StandardCharsets.UTF_8);
        return "https://t.me/share/url?url=" + URLEncoder.encode(downloadUrl, StandardCharsets.UTF_8)
                + "&text=" + encoded;
    }
}