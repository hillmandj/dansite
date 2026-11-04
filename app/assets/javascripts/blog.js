// Blog admin behaviour (replaces the old jQuery posts.js).
//  - "Preview" renders the Textile content server-side and shows it in place of the form.
//  - "Save Draft" on the new-post page re-targets the form at /drafts.
//  - Forms with data-confirm ask before submitting (used for delete buttons).
document.addEventListener("DOMContentLoaded", () => {
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

  document.addEventListener("submit", (event) => {
    const message = event.target.dataset?.confirm;
    if (message && !window.confirm(message)) event.preventDefault();
  });

  const contentField = document.querySelector('[name$="[content]"]');
  const form = contentField?.form;
  if (!form) return;

  const titleField = form.querySelector('[name$="[title]"]');
  const header = document.getElementById("post-header");
  const preview = {
    title: document.getElementById("preview-title"),
    container: document.getElementById("preview-content-container"),
    content: document.getElementById("preview-content"),
  };

  const show = (el, visible) => { if (el) el.style.display = visible ? "" : "none"; };
  show(preview.container, false);

  document.getElementById("post-preview")?.addEventListener("click", async (event) => {
    event.preventDefault();
    const response = await fetch("preview", {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken, Accept: "application/json" },
      body: JSON.stringify({ title: titleField.value, content: contentField.value }),
    });
    if (!response.ok) return;
    const data = await response.json();

    show(form, false);
    show(header, false);
    preview.title.textContent = data.preview_title;
    preview.content.innerHTML = data.preview_content;
    show(preview.title, true);
    show(preview.container, true);
  });

  document.getElementById("preview-hide")?.addEventListener("click", (event) => {
    event.preventDefault();
    show(preview.title, false);
    show(preview.container, false);
    show(header, true);
    show(form, true);
  });

  document.getElementById("save-draft")?.addEventListener("click", (event) => {
    event.preventDefault();
    form.action = "/drafts";
    titleField.name = "draft[title]";
    contentField.name = "draft[content]";
    form.querySelector('input[name="_method"]')?.remove();
    form.submit();
  });
});
