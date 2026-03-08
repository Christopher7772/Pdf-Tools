
package Model;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;

import org.apache.poi.xwpf.usermodel.*;
import org.apache.poi.xssf.usermodel.*;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * Contient la logique de conversion (couche Model / Service).
 */
public class ConversionService {

    public enum Mode {
        PDF_TO_WORD,
        WORD_TO_PDF,
        PDF_TO_EXCEL
    }

    /* ================= PDF -> WORD ================= */
    public void pdfToWord(Path pdf, Path outDocx) throws Exception {

        if (!Files.exists(pdf)) {
            throw new FileNotFoundException("PDF introuvable : " + pdf);
        }

        try (PDDocument document = PDDocument.load(Files.newInputStream(pdf));
             XWPFDocument wordDoc = new XWPFDocument();
             FileOutputStream fos = new FileOutputStream(outDocx.toFile())) {

            PDFTextStripper stripper = new PDFTextStripper();
            String text = stripper.getText(document);

            String[] lines = text.split("\\R");
            for (String line : lines) {
                XWPFParagraph p = wordDoc.createParagraph();
                XWPFRun run = p.createRun();
                run.setText(line);
            }

            wordDoc.write(fos);
        }
    }

    /* ================= PDF -> EXCEL ================= */
    public void pdfToExcel(Path pdf, Path outXlsx) throws Exception {

        if (!Files.exists(pdf)) {
            throw new FileNotFoundException("PDF introuvable : " + pdf);
        }

        try (PDDocument document = PDDocument.load(Files.newInputStream(pdf));
             XSSFWorkbook workbook = new XSSFWorkbook();
             FileOutputStream fos = new FileOutputStream(outXlsx.toFile())) {

            XSSFSheet sheet = workbook.createSheet("PDF_Content");

            PDFTextStripper stripper = new PDFTextStripper();
            String text = stripper.getText(document);

            String[] lines = text.split("\\R");
            int rowIndex = 0;

            for (String line : lines) {
                XSSFRow row = sheet.createRow(rowIndex++);
                row.createCell(0).setCellValue(line);
            }

            sheet.autoSizeColumn(0);
            workbook.write(fos);
        }
    }

    /* ================= WORD -> PDF (LibreOffice) ================= */
    public void wordToPdfWithLibreOffice(Path docx, Path outPdf) throws Exception {

        if (!Files.exists(docx)) {
            throw new FileNotFoundException("DOCX introuvable : " + docx);
        }

        // Dossier temporaire pour LibreOffice
        Path tempDir = Files.createTempDirectory("libreoffice_out");

        // CHEMIN ABSOLU VERS LibreOffice (Windows 64 bits)
        String sofficePath = "C:\\Program Files\\LibreOffice\\program\\soffice.exe";

        // 👉 Si LibreOffice est en 32 bits, utilise plutôt :
        // String sofficePath = "C:\\Program Files (x86)\\LibreOffice\\program\\soffice.exe";

        ProcessBuilder pb = new ProcessBuilder(
                sofficePath,
                "--headless",
                "--convert-to", "pdf",
                "--outdir", tempDir.toAbsolutePath().toString(),
                docx.toAbsolutePath().toString()
        );

        pb.redirectErrorStream(true);
        Process process = pb.start();

        // Lire la sortie LibreOffice (debug)
        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(process.getInputStream()))) {
            while (br.readLine() != null) {}
        }

        int exitCode = process.waitFor();
        if (exitCode != 0) {
            throw new RuntimeException("LibreOffice a échoué (code=" + exitCode + ")");
        }

        // Nom du PDF généré
        String pdfName = docx.getFileName().toString()
                .replaceAll("(?i)\\.docx$", ".pdf");

        Path generatedPdf = tempDir.resolve(pdfName);

        if (!Files.exists(generatedPdf)) {
            throw new FileNotFoundException("PDF généré introuvable : " + generatedPdf);
        }

        // Copier vers le chemin final
        Files.copy(generatedPdf, outPdf,
                java.nio.file.StandardCopyOption.REPLACE_EXISTING);
    }
}

