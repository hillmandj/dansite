// Security token for hand-written fetch() calls to Rails.
//
// Use the XSRF-TOKEN cookie, which Rails refreshes on every Inertia response
// (including right after login). The <meta name="csrf-token"> tag is only
// written on a full page load, so it goes stale after logging in without a
// reload. inertia_rails accepts the cookie value in the X-XSRF-TOKEN header.
export function csrfHeaders() {
  const cookie = document.cookie.split('; ').find((c) => c.startsWith('XSRF-TOKEN='))
  if (cookie) return { 'X-XSRF-TOKEN': decodeURIComponent(cookie.slice('XSRF-TOKEN='.length)) }

  const meta = document.querySelector('meta[name="csrf-token"]')?.content
  return meta ? { 'X-CSRF-Token': meta } : {}
}
