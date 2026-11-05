import { usePage } from '@inertiajs/react'
import { useEffect, useState } from 'react'

// Shows the Rails flash (notice/alert) briefly at the bottom of the screen.
export default function Toast() {
  const { flash } = usePage()
  const message = flash?.alert || flash?.notice
  const [visible, setVisible] = useState(false)

  useEffect(() => {
    if (!message) return
    setVisible(true)
    const timer = setTimeout(() => setVisible(false), 2600)
    return () => clearTimeout(timer)
  }, [message, flash])

  return (
    <div
      role="status"
      aria-live="polite"
      className={`fixed bottom-6 left-1/2 z-50 -translate-x-1/2 rounded-[9px] px-4 py-2.5 text-[13px] shadow-lg transition-all duration-300 ${
        flash?.alert ? 'bg-red text-white' : 'bg-head text-bg'
      } ${visible ? 'translate-y-0 opacity-100' : 'pointer-events-none translate-y-4 opacity-0'}`}
    >
      {message}
    </div>
  )
}
