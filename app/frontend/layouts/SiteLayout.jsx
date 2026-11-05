import { Link } from '@inertiajs/react'
import ThemeToggle from '../components/ThemeToggle'
import photo from '../assets/dan.jpg'

const NAV = [
  ['Interests', '/#interests'],
  ['Work', '/#work'],
  ['Writing', '/#writing'],
  ['Contact', '/#contact'],
]

export default function SiteLayout({ children }) {
  return (
    <>
      <header className="sticky top-0 z-20 border-b border-line-soft bg-bg/85 backdrop-blur-md">
        <div className="wrap flex h-[60px] items-center justify-between gap-4">
          <Link href="/" className="flex items-center gap-2.5 font-semibold text-head">
            <img src={photo} alt="" className="h-7 w-7 rounded-full" />
            Dan Hillman
          </Link>
          <div className="flex items-center gap-6">
            <nav className="hidden gap-6 text-sm text-muted md:flex">
              {NAV.map(([label, href]) => (
                <a key={href} href={href} className="hover:text-blue">{label}</a>
              ))}
            </nav>
            <ThemeToggle />
          </div>
        </div>
      </header>

      <main>{children}</main>

      <footer className="wrap mt-10 pb-14">
        <div className="flex flex-wrap justify-between gap-3 border-t border-line-soft pt-6 font-mono text-xs text-faint">
          <span>© {new Date().getFullYear()} Daniel Hillman</span>
          <span>Rails + React on a single DigitalOcean droplet</span>
        </div>
      </footer>
    </>
  )
}
