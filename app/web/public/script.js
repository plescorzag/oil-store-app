const result = document.getElementById("result");
const catalog = document.getElementById("catalog");

async function loadCatalog() {
  const res = await fetch("/api/catalog");
  const data = await res.json();
  catalog.innerHTML = data.items.map(item => `
    <article class="card">
      <h3>${item.name}</h3>
      <span class="note">${item.note}</span>
      <div class="price">$${item.price.toFixed(2)}</div>
    </article>
  `).join("");
}

async function runProbe(endpoint) {
  result.textContent = "Running…";
  const res = await fetch(endpoint);
  const data = await res.json();
  result.textContent = JSON.stringify(data, null, 2);
}

document.querySelectorAll("button[data-endpoint]").forEach(btn => {
  btn.addEventListener("click", () => runProbe(btn.dataset.endpoint));
});

loadCatalog();
