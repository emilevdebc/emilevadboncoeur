document.addEventListener("DOMContentLoaded", () => {
  const refs = document.getElementById("refs");
  if (!refs) return;

  if (refs.dataset.enhanced === "true") return;
  refs.dataset.enhanced = "true";

  const entries = Array.from(refs.querySelectorAll(".csl-entry"));
  if (entries.length === 0) return;

  const groups = new Map();
  for (const el of entries) {
    const text = el.textContent || "";
    const m = text.match(/\b(19|20)\d{2}\b/);
    const year = m ? parseInt(m[0], 10) : 0;
    if (!groups.has(year)) groups.set(year, []);
    groups.get(year).push(el);
  }

  const years = Array.from(groups.keys())
    .filter(y => y !== 0)
    .sort((a, b) => b - a);

  refs.innerHTML = "";

  const boldMyName = (el) => {
    let html = el.innerHTML;
    html = html
      .replaceAll("Émile Vadboncoeur", "<strong>Émile Vadboncoeur</strong>")
      .replaceAll("É. Vadboncoeur", "<strong>É. Vadboncoeur</strong>")
      .replaceAll("Vadboncoeur, Émile", "<strong>Vadboncoeur, Émile</strong>")
      .replaceAll("Vadboncoeur, É.", "<strong>Vadboncoeur, É.</strong>");
    el.innerHTML = html;
  };

  for (const y of years) {
    const h = document.createElement("h2");
    h.className = "pub-year";
    h.textContent = String(y);
    refs.appendChild(h);

    for (const el of groups.get(y)) {
      boldMyName(el);
      refs.appendChild(el);
    }
  }

  if (groups.has(0)) {
    const h = document.createElement("h2");
    h.className = "pub-year";
    h.textContent = "Other";
    refs.appendChild(h);

    for (const el of groups.get(0)) {
      boldMyName(el);
      refs.appendChild(el);
    }
  }
});
