
package Controller;

import Util.FileStore;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Path;


/**
 * Sert le fichier en inline (pour preview PDF dans iframe):
 * /view?id=<resultId>
 */
@WebServlet("/view")
public class ViewServlet extends HttpServlet {

    private FileStore store;

    @Override
    public void init() throws ServletException {
        try {
            store = new FileStore();
        } catch (IOException ex) {
            System.getLogger(ViewServlet.class.getName()).log(System.Logger.Level.ERROR, (String) null, ex);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String id = req.getParameter("id");
        if (id == null) {
            resp.sendError(400, "Paramètre id manquant");
            return;
        }

        Path file = store.resolveByIdPrefix(id);
        if (file == null || !file.toFile().exists()) {
            resp.sendError(404, "Fichier introuvable");
            return;
        }

        String name = file.getFileName().toString();
        String mime = getServletContext().getMimeType(name);
        if (mime == null) mime = "application/octet-stream";

        // Inline = affichage dans navigateur si possible (PDF)
        resp.setContentType(mime);
        resp.setHeader("Content-Disposition", "inline; filename=\"" + name + "\"");

        try (InputStream in = new FileInputStream(file.toFile());
             OutputStream out = resp.getOutputStream()) {
            byte[] buf = new byte[8192];
            int r;
            while ((r = in.read(buf)) != -1) out.write(buf, 0, r);
        }
    }
}

