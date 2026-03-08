package Controller;

import Model.ConversionService;
import Model.ConversionService.Mode;
import Util.FileStore;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.nio.file.Path;
import jakarta.servlet.annotation.WebServlet;
/**
 * Reçoit le fichier + le mode, sauvegarde, puis redirige vers /convert.
 */
@WebServlet("/upload")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,     // 1 MB
        maxFileSize = 20 * 1024 * 1024,      // 20 MB
        maxRequestSize = 20 * 1024 * 1024    // 20 MB
)
public class UploadServlet extends HttpServlet {

    private FileStore store;
    private ConversionService service;

    @Override
    public void init() throws ServletException {
        try {
            store = new FileStore();
            service = new ConversionService(); // ✅ manquait
        } catch (IOException e) {
            throw new ServletException("Erreur initialisation UploadServlet", e);
        }
    }

    /**
     * Récupère le nom original du fichier uploadé
     * Compatible Jakarta Servlet (Tomcat 10)
     */
    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) return "file";

        for (String token : contentDisp.split(";")) {
            token = token.trim();
            if (token.startsWith("filename")) {
                String name = token.substring(token.indexOf('=') + 1)
                                  .trim()
                                  .replace("\"", "");

                // Sécurité navigateur (C:\fakepath\file.pdf)
                int slash = Math.max(name.lastIndexOf('/'), name.lastIndexOf('\\'));
                return (slash >= 0) ? name.substring(slash + 1) : name;
            }
        }
        return "file";
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 1) Récupération des données du formulaire
        Part filePart = req.getPart("file");
        String modeStr = req.getParameter("mode");

        if (filePart == null || modeStr == null || filePart.getSize() == 0) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Fichier ou mode de conversion manquant.");
            return;
        }

        // 2) Conversion du mode
        Mode mode = Mode.valueOf(modeStr);

        // 3) Nom du fichier
        String submitted = extractFileName(filePart);
        String contentType = filePart.getContentType();

        // 4) Génération ID unique
        String uploadId = store.newId();

        // 5) Sauvegarde du fichier
        Path saved = store.save(filePart.getInputStream(), uploadId, submitted);

        // 6) Sauvegarde des infos en session
        HttpSession session = req.getSession(true);
        session.setAttribute("uploadId", uploadId);
        session.setAttribute("uploadPath", saved.toString());
        session.setAttribute("uploadName", submitted);
        session.setAttribute("uploadType", contentType);
        session.setAttribute("mode", mode.name());

        // 7) Redirection vers ConvertServlet
        resp.sendRedirect(req.getContextPath() + "/convert");
    }
}

