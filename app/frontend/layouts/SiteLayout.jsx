import { Link, usePage } from '@inertiajs/react'
import { useEffect, useRef } from 'react'
import AdminBar from '../components/AdminBar'
import Statusline from '../components/Statusline'
import ThemeToggle from '../components/ThemeToggle'
import Toast from '../components/Toast'
import useActiveSection from '../lib/useActiveSection'

const NAV = [
  ['Interests', '/#interests', 'interests'],
  ['Work', '/#work', 'work'],
  ['Writing', '/#writing', 'writing'],
  ['Contact', '/#contact', 'contact'],
]

// The "file" the statusline shows for each page.
function statuslineFile(component, props, section) {
  if (component === 'home/index') return `~/${section?.file || 'index.md'}`
  if (component === 'posts/index') return '~/blog/index.md'
  if (component === 'posts/show') return `~/blog/${props.post.slug}.md`
  if (component === 'errors/not_found') return '[No Name]'
  return null
}

// Keeps <html data-scheme> in sync with the site theme. The server sets it on first load;
// this applies a change made in the admin without a full page reload.
function useSiteTheme(scheme) {
  const first = useRef(true)
  useEffect(() => {
    const root = document.documentElement
    if (root.dataset.scheme === scheme) return
    if (!first.current) {
      root.classList.add('theming')
      setTimeout(() => root.classList.remove('theming'), 450)
    }
    root.dataset.scheme = scheme
    first.current = false
  }, [scheme])
}

export default function SiteLayout({ children, hideNav = false }) {
  const { props, url, component } = usePage()
  const section = useActiveSection(url)
  const file = hideNav ? null : statuslineFile(component, props, section)
  useSiteTheme(props.site_theme)

  return (
    <>
      {props.admin && <AdminBar />}
      <header className="sticky top-0 z-20 border-b border-line-soft bg-bg/85 backdrop-blur-md term:bg-bg-alt term:backdrop-blur-none">
        <div className="wrap flex h-[60px] items-center justify-between gap-4 term:h-12">
          <Link href="/" className="font-semibold text-head term:font-mono term:text-sm term:font-medium">
            <span className="term:hidden">Dan Hillman</span>
            <span className="hidden term:inline"><span className="text-hot">~/</span>dan-hillman</span>
          </Link>
          <div className="flex items-center gap-6 term:gap-3.5">
            {!hideNav && (
              <nav className="hidden gap-6 text-sm text-muted md:flex term:gap-0.5 term:font-mono term:text-[13px] term:lowercase">
                {NAV.map(([label, href, id], i) => {
                  const active = component === 'home/index' && section?.id === id
                  return (
                    <a
                      key={href}
                      href={href}
                      className={`hover:text-link term:rounded term:px-3 term:py-1 term:hover:bg-panel term:hover:text-head ${
                        active ? 'term:bg-panel term:text-head term:shadow-[inset_0_-2px_0_var(--c-hot)]' : ''
                      }`}
                    >
                      <span className={`mr-1.5 hidden term:inline ${active ? 'text-hot' : 'text-faint'}`}>{i + 1}</span>
                      {label}
                    </a>
                  )
                })}
              </nav>
            )}
            <ThemeToggle />
          </div>
        </div>
      </header>

      <main>{children}</main>
      <Toast />

      <footer className="wrap mt-10 pb-14">
        <div className="flex flex-wrap justify-between gap-3 border-t border-line-soft pt-6 font-mono text-xs text-faint">
          <span>© {new Date().getFullYear()} Daniel Hillman</span>
          <span>Rails + React on a single DigitalOcean droplet</span>
        </div>
      </footer>

      {file && <Statusline file={file} scheme={props.site_theme} />}
    </>
  )
}
