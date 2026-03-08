

package Controller;

import Util.FileStore;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * Gère le téléchargement du fichier converti
 */
@WebServlet("/download")
public class DownloadServlet extends HttpServlet {

    private FileStore store;

    @Override
    public void init() throws ServletException {
        try {
            store = new FileStore();
        } catch (IOException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 1) Récupérer l’ID du fichier
        String id = req.getParameter("id");
        if (id == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID manquant");
            return;
        }

        // 2) Récupérer les infos stockées en session
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String fileName = (String) session.getAttribute("resultName");
        String mime = (String) session.getAttribute("resultMime");

        if (fileName == null || mime == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // 3) Localiser le fichier sur disque
        Path file = store.getBaseDir().resolve(id + "_" + fileName);
        if (!Files.exists(file)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // 4) Préparer la réponse HTTP
        resp.setContentType(mime);
        resp.setContentLengthLong(Files.size(file));

        // Force le téléchargement
        resp.setHeader(
                "Content-Disposition",
                "attachment; filename=\"" + fileName + "\""
        );

        // 5) Écrire le fichier dans la réponse
        try (InputStream in = Files.newInputStream(file);
             OutputStream out = resp.getOutputStream()) {

            byte[] buffer = new byte[8192];
            int len;
            while ((len = in.read(buffer)) != -1) {
                out.write(buffer, 0, len);
            }
        }
    }
}


