document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("#refs .csl-entry").forEach(el => {
    // Avoid double-wrapping if you re-render often
    let html = el.innerHTML;

    // Common variants in rendered bibliographies:
    html = html.replaceAll("Émile Vadboncoeur", "<strong>Émile Vadboncoeur</strong>");
    html = html.replaceAll("É. Vadboncoeur", "<strong>É. Vadboncoeur</strong>");
    html = html.replaceAll("Vadboncoeur, Émile", "<strong>Vadboncoeur, Émile</strong>");
    html = html.replaceAll("Vadboncoeur, É.", "<strong>Vadboncoeur, É.</strong>");

    el.innerHTML = html;
  });
});
