package Controller;

import jakarta.servlet.annotation.WebServlet;
import Model.ConversionService;
import Model.ConversionService.Mode;
import static Model.ConversionService.Mode.PDF_TO_EXCEL;
import static Model.ConversionService.Mode.PDF_TO_WORD;
import Util.FileStore;
import Util.ShareLinkUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

/**
 * Exécute la conversion et prépare :
 * - le fichier final (download)
 * - un PDF d’aperçu (preview)
 */
@WebServlet("/convert")
public class ConvertServlet extends HttpServlet {

    private FileStore store;
    private ConversionService service;

    @Override
    public void init() throws ServletException {
        try {
            store = new FileStore();
            service = new ConversionService();
        } catch (IOException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        String uploadPath = (String) session.getAttribute("uploadPath");
        String uploadName = (String) session.getAttribute("uploadName");
        String modeStr = (String) session.getAttribute("mode");

        if (uploadPath == null || uploadName == null || modeStr == null) {
            resp.sendRedirect(req.getContextPath() + "/index.html");
            return;
        }

        Mode mode = Mode.valueOf(modeStr);

        // IDs
        String resultId = store.newId();
        String previewId = store.newId();

        try {
            Path in = Paths.get(uploadPath);
            Path outFinal;
            Path outPreview;

            String resultName;
            String resultMime;



switch (mode) {

  case PDF_TO_WORD:
    resultName = uploadName.replaceAll("(?i)\\.pdf$", "") + ".docx";
    outFinal = store.getBaseDir().resolve(resultId + "_" + resultName);
    service.pdfToWord(in, outFinal);
    resultMime = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";

    // ✅ Preview = PDF d'origine
    outPreview = store.getBaseDir().resolve(previewId + "_preview.pdf");
    Files.copy(in, outPreview, StandardCopyOption.REPLACE_EXISTING);
    break;

  case PDF_TO_EXCEL:
    resultName = uploadName.replaceAll("(?i)\\.pdf$", "") + ".xlsx";
    outFinal = store.getBaseDir().resolve(resultId + "_" + resultName);
    service.pdfToExcel(in, outFinal);
    resultMime = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

    // ✅ Preview = PDF d'origine
    outPreview = store.getBaseDir().resolve(previewId + "_preview.pdf");
    Files.copy(in, outPreview, StandardCopyOption.REPLACE_EXISTING);
    break;

  default: // WORD_TO_PDF
    resultName = uploadName.replaceAll("(?i)\\.docx$", "") + ".pdf";
    outFinal = store.getBaseDir().resolve(resultId + "_" + resultName);
    service.wordToPdfWithLibreOffice(in, outFinal);
    resultMime = "application/pdf";

    // ✅ Preview = PDF final
    previewId = resultId;
    break;
}


            // URL téléchargement
            String downloadUrl = req.getRequestURL().toString().replace("/convert", "")
                    + "/download?id=" + resultId;

            // Liens partage
            String wa = ShareLinkUtil.whatsappShareLink(downloadUrl);
            String tg = ShareLinkUtil.telegramShareLink(downloadUrl);

            // Session
            session.setAttribute("resultId", resultId);
            session.setAttribute("previewId", previewId);
            session.setAttribute("resultName", resultName);
            session.setAttribute("resultMime", resultMime);
            session.setAttribute("waLink", wa);
            session.setAttribute("tgLink", tg);

            resp.sendRedirect(req.getContextPath() + "/result.jsp");

        } catch (Exception e) {
            throw new ServletException("Conversion échouée : " + e.getMessage(), e);
        }
    }
}


