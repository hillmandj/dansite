// Dates arrive as "YYYY-MM-DD"; format them without shifting by the visitor's timezone.
export const longDate = (iso) =>
  new Date(`${iso}T00:00:00Z`).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric', timeZone: 'UTC' })
