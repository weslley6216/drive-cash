export function loadExportPreview(element) {
  const form = element.closest('form')
  if (!form) return

  const body = new URLSearchParams(new FormData(form))
  body.delete('authenticity_token')

  const frame = document.querySelector('[id="export-summary"]')
  if (frame) {
    frame.src = `/exports/preview?${body}`
  }
}
