import { useEffect, useRef } from 'react'

const LEVELS = ['var(--c-h0)', 'var(--c-h1)', 'var(--c-h2)', 'var(--c-h3)', 'var(--c-h4)']

const plural = (n, word) => `${n} ${word}${n === 1 ? '' : 's'}`

// GitHub-style contribution grid: one column per week, Sunday at the top.
// `days` is [[ "YYYY-MM-DD", count, level(0-4) ], ...] in date order.
export default function Heatmap({ days, total, activeDays }) {
  const grid = useRef(null)

  // On narrow screens the grid scrolls; start at the most recent weeks.
  useEffect(() => {
    if (grid.current) grid.current.scrollLeft = grid.current.scrollWidth
  }, [])

  const leadingBlanks = new Date(`${days[0][0]}T00:00:00`).getDay()

  return (
    <div className="panel p-[22px]">
      <div className="mb-3.5 hidden justify-between font-mono text-xs text-faint term:flex">
        <span className="text-muted"><b className="font-medium text-hot">:</b>Contributions</span>
        <span>last 12 months</span>
      </div>
      <div
        ref={grid}
        className="grid grid-flow-col justify-between gap-[3px] overflow-x-auto"
        style={{ gridTemplateRows: 'repeat(7, 11px)', gridAutoColumns: '11px' }}
        role="img"
        aria-label={`${plural(total, 'contribution')} on ${plural(activeDays, 'day')} in the last year`}
      >
        {Array.from({ length: leadingBlanks }, (_, i) => <span key={`pad-${i}`} />)}
        {days.map(([date, count, level]) => (
          <span
            key={date}
            title={`${plural(count, 'contribution')} on ${date}`}
            className="block h-[11px] w-[11px] rounded-[3px]"
            style={{ background: LEVELS[level] }}
          />
        ))}
      </div>

      <div className="mt-3.5 flex flex-wrap items-center justify-between gap-2 text-[13px] text-muted">
        <span>
          <b className="font-semibold text-head">{total}</b> contributions on{' '}
          <b className="font-semibold text-head">{activeDays}</b> days in the last year
          <span className="font-mono text-faint"> · mostly private repos</span>
        </span>
        <span className="flex items-center gap-[3px] text-xs text-faint">
          Less
          {LEVELS.map((bg) => <i key={bg} className="inline-block h-[11px] w-[11px] rounded-[3px]" style={{ background: bg }} />)}
          More
        </span>
      </div>
    </div>
  )
}
