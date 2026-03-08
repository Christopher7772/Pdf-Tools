<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String resultId   = (String) session.getAttribute("resultId");
    String previewId  = (String) session.getAttribute("previewId");
    String resultName = (String) session.getAttribute("resultName");
    String waLink     = (String) session.getAttribute("waLink");
    String tgLink     = (String) session.getAttribute("tgLink");

    if (resultId == null || resultName == null) {
        response.sendRedirect("index.jsp"); // ou index.html selon ton accueil
        return;
    }

    String ctx = request.getContextPath(); // ex: /Conversions
    String previewUrl  = ctx + "/view?id=" + previewId;
    String downloadUrl = ctx + "/download?id=" + resultId;

    // fallback si waLink / tgLink pas en session
    if (waLink == null) waLink = "";
    if (tgLink == null) tgLink = "";
%>

<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Résultat — PDF Tools</title>

  <!-- CSS du projet -->
  <link rel="stylesheet" href="<%= ctx %>/css/style.css" />
</head>
<body>

<header class="navbar">
  <div class="container nav__inner">
    <a class="brand" href="<%= ctx %>/index.jsp">
      <span class="brand__logo">PDF</span>
      <span class="brand__name">PDF Tools</span>
    </a>

    <nav class="nav">
      <a class="nav__link" href="<%= ctx %>/index.jsp">Nouvelle conversion</a>
    </nav>
  </div>
</header>

<main class="container">
  <section class="result-wrap">
    <div class="result-head">
      <h1> Conversion terminée !</h1>
      <p>Votre fichier <strong><%= resultName %></strong> est prêt.</p>
    </div>

    <div class="preview-card">
      <div class="preview-card__top">
        <div class="badge">Aperçu PDF</div>
        <div class="muted">L’aperçu est toujours un PDF (original ou généré).</div>
      </div>

      <div class="preview-frame">
        <% if (previewId != null) { %>
          <iframe src="<%= previewUrl %>" title="Aperçu PDF" loading="lazy"></iframe>
        <% } else { %>
          <div class="muted" style="padding:14px;">
            Aperçu indisponible.
          </div>
        <% } %>
      </div>
    </div>

    <div class="btn-row">
      <a class="btn btn-danger" href="<%= downloadUrl %>"> Télécharger</a>

      <% if (!waLink.isBlank()) { %>
        <a class="btn btn-wa" target="_blank" rel="noopener" href="<%= waLink %>"> WhatsApp</a>
      <% } %>

      <% if (!tgLink.isBlank()) { %>
        <a class="btn btn-tg" target="_blank" rel="noopener" href="<%= tgLink %>">️ Telegram</a>
      <% } %>
    </div>

    <div class="back-row">
      <a class="link-back" href="<%= ctx %>/index.jsp">← Retour à l’accueil</a>
    </div>
  </section>
</main>

<footer class="footer">
  <div class="container footer__inner">
    <div class="security">Sécurité garantie – Vos fichiers sont supprimés après traitement.</div>
    <div class="links">
      <a href="#">Politique de confidentialité</a> •
      <a href="#">Conditions d’utilisation</a> •
      <a href="#">Contact</a>
    </div>
  </div>
</footer>

</body>
</html>
