import { useEffect, useState } from 'react'

const currentTheme = () =>
  typeof document === 'undefined' ? 'dark' : document.documentElement.dataset.theme || 'dark'

// Switches light/dark. Colors ease over ~0.4s (see html.theming in application.css)
// and the sun/moon icons rotate into each other.
export default function ThemeToggle() {
  const [theme, setTheme] = useState('dark')

  useEffect(() => setTheme(currentTheme()), [])

  const toggle = () => {
    const root = document.documentElement
    const next = currentTheme() === 'dark' ? 'light' : 'dark'
    const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches

    if (!reduceMotion) root.classList.add('theming')
    root.dataset.theme = next
    try { localStorage.setItem('theme', next) } catch { /* storage unavailable */ }
    setTheme(next)

    clearTimeout(window.__themeTimer)
    window.__themeTimer = setTimeout(() => root.classList.remove('theming'), 450)
  }

  const icon = (visible) =>
    `absolute inset-0 m-auto h-[17px] w-[17px] transition-[transform,opacity] duration-[450ms] ease-[cubic-bezier(.4,0,.2,1)] ${
      visible ? 'opacity-100' : 'opacity-0 -rotate-[120deg] scale-60'
    }`

  return (
    <button
      type="button"
      onClick={toggle}
      aria-label={`Switch to ${theme === 'dark' ? 'light' : 'dark'} theme`}
      className="relative h-9 w-9 overflow-hidden rounded-[9px] border border-line bg-panel text-text transition-colors hover:border-blue hover:text-blue"
    >
      <svg className={icon(theme === 'dark')} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        <path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z" />
      </svg>
      <svg className={icon(theme === 'light')} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" aria-hidden="true">
        <circle cx="12" cy="12" r="4" />
        <path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" />
      </svg>
    </button>
  )
}
