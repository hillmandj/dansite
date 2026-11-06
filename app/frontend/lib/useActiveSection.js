import { useEffect, useState } from 'react'

// Tracks which page section (an element with data-file="…") is in view while scrolling.
// Used by the nav tabs and the statusline. Returns { id, file } or null on pages without sections.
export default function useActiveSection(url) {
  const [section, setSection] = useState(null)

  useEffect(() => {
    const elements = [...document.querySelectorAll('[data-file]')]
    if (elements.length === 0) {
      setSection(null)
      return
    }

    const update = () => {
      let current = elements[0]
      for (const el of elements) {
        if (el.getBoundingClientRect().top < window.innerHeight * 0.4) current = el
      }
      setSection((prev) => (prev?.file === current.dataset.file ? prev : { id: current.id, file: current.dataset.file }))
    }

    update()
    window.addEventListener('scroll', update, { passive: true })
    return () => window.removeEventListener('scroll', update)
  }, [url])

  return section
}
