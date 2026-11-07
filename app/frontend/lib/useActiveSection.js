import { useCallback, useEffect, useRef, useState } from 'react'

const toSection = (el) => ({ id: el.id, file: el.dataset.file })

// Tracks which page section (an element with data-file="…") is in view while scrolling.
// Used by the nav tabs and the statusline.
// Returns [section, select]: section is { id, file } or null on pages without sections;
// select(id) marks a section active right away (call it when a nav tab is clicked).
export default function useActiveSection(url) {
  const [section, setSection] = useState(null)
  const clicked = useRef(null) // while the page scrolls to a clicked tab, keep that tab active
  const fallback = useRef(null)

  useEffect(() => {
    const elements = [...document.querySelectorAll('[data-file]')]
    if (elements.length === 0) {
      setSection(null)
      return
    }

    const update = () => {
      if (clicked.current) return

      // The section whose top has passed 40% of the way down the window...
      let current = elements[0]
      for (const el of elements) {
        if (el.getBoundingClientRect().top < window.innerHeight * 0.4) current = el
      }
      // ...unless we're at the bottom: short sections at the end can never get that far up.
      const atBottom = window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 2
      if (atBottom) current = elements[elements.length - 1]

      setSection((prev) => (prev?.file === current.dataset.file ? prev : toSection(current)))
    }

    const release = () => {
      clicked.current = null
    }

    // Hand control back to scrolling once the jump finishes, or as soon as the visitor scrolls themselves.
    const releaseOn = ['scrollend', 'wheel', 'touchmove', 'keydown']

    update()
    window.addEventListener('scroll', update, { passive: true })
    releaseOn.forEach((name) => window.addEventListener(name, release, { passive: true }))
    return () => {
      window.removeEventListener('scroll', update)
      releaseOn.forEach((name) => window.removeEventListener(name, release))
      clearTimeout(fallback.current)
    }
  }, [url])

  const select = useCallback((id) => {
    const el = document.getElementById(id)
    if (!el?.dataset.file) return
    clicked.current = id
    setSection(toSection(el))
    // Browsers without the scrollend event: release after the smooth scroll has had time to finish.
    clearTimeout(fallback.current)
    if (!('onscrollend' in window)) fallback.current = setTimeout(() => { clicked.current = null }, 1500)
  }, [])

  return [section, select]
}
