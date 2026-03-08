document.addEventListener("DOMContentLoaded", () => {
  const fileInput = document.getElementById("fileInput");
  const fileName = document.getElementById("fileName");
  const dropZone = document.getElementById("dropZone");
  const modeInput = document.getElementById("mode");
  const btnConvert = document.getElementById("btnConvert");
  const convertHint = document.getElementById("convertHint");

  // expose pour onclick="selectFile()"
  window.selectFile = function () {
    if (!fileInput) return;
    fileInput.click();
  };

  // expose pour onclick="toggleMenu()"
  window.toggleMenu = function () {
    const nav = document.getElementById("navMenu");
    if (nav) nav.classList.toggle("open");
  };

  function hasFile() {
    return fileInput && fileInput.files && fileInput.files.length > 0;
  }

  function hasMode() {
    return modeInput && modeInput.value && modeInput.value.trim().length > 0;
  }

  function refreshConvertState() {
    const ok = hasFile() && hasMode();
    if (btnConvert) {
      btnConvert.disabled = !ok;
      btnConvert.classList.toggle("active", ok);
    }
    if (!convertHint) return;

    if (!hasFile() && !hasMode()) convertHint.textContent = "1) Choisis un fichier • 2) Choisis une conversion • 3) Convertir";
    else if (!hasFile()) convertHint.textContent = "Choisis un fichier pour continuer";
    else if (!hasMode()) convertHint.textContent = "Choisis une conversion (Word/PDF/Excel)";
    else convertHint.textContent = "Prêt ✅ Clique sur Convertir →";
  }

  if (fileInput) {
    fileInput.addEventListener("change", () => {
      fileName.textContent = hasFile() ? ("Fichier : " + fileInput.files[0].name) : "";
      refreshConvertState();
    });
  }

  // Drag & drop
  if (dropZone) {
    dropZone.addEventListener("dragover", (e) => {
      e.preventDefault();
      dropZone.classList.add("dragover");
    });

    dropZone.addEventListener("dragleave", () => dropZone.classList.remove("dragover"));

    dropZone.addEventListener("drop", (e) => {
      e.preventDefault();
      dropZone.classList.remove("dragover");

      if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
        fileInput.files = e.dataTransfer.files;
        fileName.textContent = "Fichier : " + e.dataTransfer.files[0].name;
        refreshConvertState();
      }
    });
  }

  // Mode buttons
  document.querySelectorAll(".tool-card").forEach((card) => {
    card.addEventListener("click", () => {
      document.querySelectorAll(".tool-card").forEach(c => c.classList.remove("selected"));
      card.classList.add("selected");
      modeInput.value = card.getAttribute("data-mode");
      refreshConvertState();
    });
  });

  refreshConvertState();
});
