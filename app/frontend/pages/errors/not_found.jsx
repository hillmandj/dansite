import { Link } from '@inertiajs/react'
import { useMemo } from 'react'
import SiteLayout from '../../layouts/SiteLayout'

// A tiny fake log tail. Timestamps and the trace id are made up on the spot.
export default function NotFound({ path }) {
  const { times, traceId } = useMemo(() => {
    const now = Date.now()
    const at = (ms) => new Date(now + ms).toISOString().slice(11, 23)
    return { times: [0, 9, 15, 24, 27].map(at), traceId: Math.random().toString(16).slice(2, 10) }
  }, [])

  const k = (text) => <span className="text-key">{text}</span>
  const s = (text) => <span className="text-str">{text}</span>
  const lines = [
    ['INFO ', 'text-green', <>request received  {k('method')}={s('GET')} {k('path')}={s(`"${path}"`)}</>],
    ['INFO ', 'text-green', 'looking for a route…'],
    ['WARN ', 'text-amber', <>checked under the couch cushions  {k('found')}={s('0')}</>],
    ['ERROR', 'text-red', <>route_not_found  {k('path')}={s(`"${path}"`)} {k('status')}={s('404')}</>],
    ['INFO ', 'text-green', <>suggesting a way home <span className="inline-block h-[15px] w-2 animate-pulse bg-muted align-[-2px]" /></>],
  ]

  return (
    <div className="mx-auto max-w-[760px] px-6 pt-20 pb-10">
      <div className="font-mono text-sm font-semibold tracking-[.08em] text-amber">404 · NOT FOUND</div>
      <h1 className="mt-2.5 mb-3.5 font-display text-[clamp(34px,5vw,50px)] leading-[1.1] font-bold tracking-[-.03em]">
        I checked the logs. There's nothing here.
      </h1>
      <p className="max-w-[560px] text-lg">
        The page you're looking for doesn't exist, moved, or never did. Here's what the server saw:
      </p>

      <div className="panel mt-8 overflow-hidden">
        <div className="flex justify-between border-b border-line-soft px-3.5 py-2.5 font-mono text-xs text-faint">
          <span>tail -f production.log</span>
          <span>trace_id={traceId}</span>
        </div>
        <pre className="overflow-x-auto px-[18px] py-4 font-mono text-[13px] leading-[1.9] whitespace-pre-wrap text-muted">
          {lines.map(([level, color, message], i) => (
            <div key={i}>
              <span className="text-faint">{times[i]}</span> <span className={`font-semibold ${color}`}>{level}</span> {message}
            </div>
          ))}
        </pre>
      </div>

      <div className="mt-[30px] flex flex-wrap gap-3">
        <Link href="/" className="btn btn-primary">Take me home</Link>
        <Link href="/blog" className="btn">Read something</Link>
        <a href="/#contact" className="btn">Report it to Dan</a>
      </div>
    </div>
  )
}

NotFound.layout = (page) => <SiteLayout>{page}</SiteLayout>
