<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>PDF Tools — Convertisseur</title>

  <!-- ✅ CSS avec contextPath -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />
</head>
<body>

<header class="navbar">
  <div class="container nav__inner">
    <a class="brand" href="${pageContext.request.contextPath}/">
      <span class="brand__logo">PDF</span>
      <span class="brand__name">PDF Tools</span>
    </a>

    <button class="menu-toggle" type="button" aria-label="Menu" onclick="toggleMenu()">☰</button>

    <nav id="navMenu" class="nav">
      <a class="nav__link" href="${pageContext.request.contextPath}/">Accueil</a>
      <a class="nav__link" href="#tools">Outils</a>
      <a class="nav__link" href="#help">Aide</a>
      
    </nav>
  </div>
</header>

<main class="container">
  <section class="hero">
    <h1>Convertis tes fichiers en <span>1 clic</span></h1>
    <p>Word ↔ PDF ↔ Excel. Simple, rapide, propre.</p>
  </section>

  <!-- ✅ FORM: action avec contextPath -->
  <form id="convertForm"
        method="post"
        action="${pageContext.request.contextPath}/upload"
        enctype="multipart/form-data"
        class="converter-card">

    <input type="hidden" id="mode" name="mode" value="" />

    <div class="drop-zone" id="dropZone">
      <div class="drop-zone__icon">️</div>

      <div class="drop-zone__text">
        <p><strong>Glissez-déposez votre fichier ici</strong></p>
        <span>PDF, DOCX · Max 20 Mo</span>
      </div>

      <!-- ✅ évite hidden, utilise display:none -->
      <input
        type="file"
        id="fileInput"
        name="file"
        style="display:none"
        accept=".pdf,.doc,.docx,.xls,.xlsx,application/pdf"
      />

      <!-- ✅ type=button obligatoire -->
      <button type="button" class="btn btn-file" onclick="selectFile()">Choisir un fichier</button>
      <p id="fileName" class="file-name"></p>
    </div>

    <section id="tools" class="tools">
      <h2>Choisis une conversion</h2>

      <div class="cards">
        <button type="button" class="tool-card blue" data-mode="WORD_TO_PDF">
          <div class="tool-card__title">Word → PDF</div>
          <div class="tool-card__desc">DOCX vers PDF (aperçu prêt)</div>
        </button>

        <button type="button" class="tool-card red" data-mode="PDF_TO_WORD">
          <div class="tool-card__title">PDF → Word</div>
          <div class="tool-card__desc">PDF vers DOCX (modifiable)</div>
        </button>

        <button type="button" class="tool-card green" data-mode="PDF_TO_EXCEL">
          <div class="tool-card__title">PDF → Excel</div>
          <div class="tool-card__desc">PDF vers XLSX (tableaux)</div>
        </button>
      </div>

      <div class="convert-bar">
        <div class="convert-hint" id="convertHint">
          1) Choisis un fichier • 2) Choisis une conversion • 3) Convertir
        </div>

        <button type="submit" id="btnConvert" class="btn btn-convert" disabled>
          Convertir →
        </button>
      </div>
    </section>

    <section id="help" class="help">
      <div class="help__card">
        <h3>Conseil</h3>
        <p>Après conversion, tu auras un <strong>aperçu PDF</strong> et les boutons <strong>télécharger</strong> / <strong>WhatsApp</strong> / <strong>Telegram</strong>.</p>
      </div>
    </section>
  </form>
</main>

<footer class="footer">
  <div class="container footer__inner">
    <div class="security">Sécurité garantie – Fichiers supprimés après traitement</div>
    <div class="links">
      <a href="#">Politique de confidentialité</a> •
      <a href="#">Conditions d’utilisation</a> •
      <a href="#">Contact</a>
    </div>
  </div>
</footer>

<!-- ✅ JS avec contextPath + en bas -->
<script src="${pageContext.request.contextPath}/js/upload.js"></script>
</body>
</html>
