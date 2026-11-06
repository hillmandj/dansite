import { useEffect, useState } from 'react'

const SCROLL_LABEL = (pct) => (pct <= 0 ? 'Top' : pct >= 100 ? 'Bot' : `${pct}%`)

// A neovim-style status bar pinned to the bottom of the window.
// Terminal themes only, desktop only, and purely decorative (hidden from screen readers).
export default function Statusline({ file, scheme }) {
  const [position, setPosition] = useState('Top')

  useEffect(() => {
    const update = () => {
      const max = document.documentElement.scrollHeight - window.innerHeight
      setPosition(SCROLL_LABEL(max > 0 ? Math.round((window.scrollY / max) * 100) : 0))
    }
    update()
    window.addEventListener('scroll', update, { passive: true })
    window.addEventListener('resize', update)
    return () => {
      window.removeEventListener('scroll', update)
      window.removeEventListener('resize', update)
    }
  }, [file])

  return (
    <div
      aria-hidden="true"
      className="fixed inset-x-0 bottom-0 z-30 hidden h-[22px] border-t border-line-soft bg-bg-alt font-mono text-[11px] leading-[22px] whitespace-nowrap text-muted term:md:flex"
    >
      <span className="bg-fill px-2.5 font-bold text-on-fill">NORMAL</span>
      <span className="bg-panel px-2.5 text-head">{file}</span>
      <span className="flex-1" />
      <span className="border-l border-line-soft px-2.5">utf-8</span>
      <span className="border-l border-line-soft px-2.5">{scheme}</span>
      <span className="bg-panel px-2.5 text-head">{position}</span>
    </div>
  )
}
