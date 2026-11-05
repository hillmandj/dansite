import { Head, Link } from '@inertiajs/react'
import SiteLayout from '../../layouts/SiteLayout'
import Heatmap from '../../components/Heatmap'
import photo from '../../assets/dan.jpg'

const LINKS = {
  email: 'mailto:hillmandj@gmail.com',
  github: 'https://github.com/hillmandj',
  linkedin: 'https://www.linkedin.com/in/hillmandj',
  vectorPr: 'https://github.com/vectordotdev/vector/pull/21274',
}

const INTERESTS = [
  {
    color: 'green',
    title: 'Observability',
    icon: <><path d="M3 3v18h18" /><path d="M7 15l4-4 3 3 5-6" /></>,
    body: (
      <>
        Figuring out what big systems are actually doing. At Zendesk I helped build our internal logging
        platform on Grafana Loki and move our log pipeline to{' '}
        <a className="link" href={LINKS.vectorPr}>Vector</a>, contributing back to the project along the way.
      </>
    ),
  },
  {
    color: 'violet',
    title: 'Developer experience',
    icon: <><path d="M16 18l6-6-6-6" /><path d="M8 6l-6 6 6 6" /></>,
    body: "Fast local setups, reliable CI, and tools that get out of the way. A lot of my favorite work has been making other engineers' days a little easier.",
  },
  {
    color: 'amber',
    title: 'Building with AI',
    icon: <><path d="M12 3l1.9 5.1L19 10l-5.1 1.9L12 17l-1.9-5.1L5 10l5.1-1.9z" /><path d="M19 17l.8 2.2L22 20l-2.2.8L19 23l-.8-2.2L16 20l2.2-.8z" /></>,
    body: "Exploring how AI fits into real engineering work, from coding assistants to small tools of my own. I'll be sharing projects here soon.",
  },
]

const ACCENT = {
  green: { icon: 'bg-green/15 text-green', hover: 'hover:border-green/50' },
  violet: { icon: 'bg-violet/15 text-violet', hover: 'hover:border-violet/50' },
  amber: { icon: 'bg-amber/15 text-amber', hover: 'hover:border-amber/50' },
}

const JOBS = [
  { company: 'Zendesk', role: 'Staff Software Engineer, SRE Observability', years: '2022 – now' },
  { company: '2U', role: 'Senior Software Engineer', years: '2019 – 2022' },
  { company: 'Handy', role: 'Software Engineer', years: '2015 – 2017' },
]

const HOBBIES = ['🚴 Biking', '⛷️ Skiing', '🏀 Basketball', '📚 Graphic novels', '🎮 Video games', '🏈 Fantasy sports']

function Section({ id, dot, title, children, className = '' }) {
  return (
    <section id={id} className={`scroll-mt-20 py-11 ${className}`} style={dot ? { '--dot': `var(--c-${dot})` } : undefined}>
      {title && <h2 className="section-title mb-5">{title}</h2>}
      {children}
    </section>
  )
}

export default function Home({ posts, contributions, settings }) {
  const postLink = (slug) => `/blog/${slug}`
  const graphicNovels = posts.find((p) => p.slug === 'my-top-five-graphic-novels')
  const fantasy = posts.find((p) => p.slug === 'memoirs-of-a-fantasy-champion')

  return (
    <>
      <Head>
        <meta name="description" content="Daniel Hillman is a Staff Software Engineer at Zendesk who builds web apps, developer tools and infrastructure." />
      </Head>

      <div className="wrap">
        {/* Intro */}
        <section className="grid grid-cols-[minmax(0,1fr)] items-center gap-7 pt-12 pb-10 md:grid-cols-[minmax(0,1fr)_auto] md:gap-14 md:pt-[88px] md:pb-16">
          <div className="min-w-0">
            <p className="mb-6 overflow-x-auto whitespace-nowrap font-mono text-[13px] text-muted">
              <span className="font-semibold text-green">INFO</span>{' '}
              <span className="text-indigo">msg</span>=<span className="text-str">"hi! welcome to my site"</span>{' '}
              <span className="text-indigo">name</span>=<span className="text-str">dan</span>{' '}
              <span className="text-indigo">status</span>=<span className="text-str">glad_you_stopped_by</span>
            </p>
            <h1 className="text-[clamp(34px,5vw,52px)] font-bold leading-[1.1] tracking-[-.03em]">Hi, I'm Dan.</h1>
            <p className="mt-3.5 max-w-[620px] text-[22px] leading-[1.45] font-medium tracking-[-.01em] text-head">
              I'm a Staff Software Engineer at Zendesk. I've spent 11+ years building web apps, developer tools and
              the infrastructure underneath them, and I still <span className="mark">love writing code</span>.
            </p>
            <div className="mt-[30px] flex flex-wrap gap-3">
              <a className="btn btn-primary" href="#contact">Say hello</a>
              <a className="btn" href={LINKS.github}>GitHub ↗</a>
              <a className="btn" href={LINKS.linkedin}>LinkedIn ↗</a>
            </div>
          </div>
          <div className="photo-ring order-first md:order-none">
            <img src={photo} alt="Daniel Hillman" />
          </div>
        </section>

        {/* GitHub activity */}
        {settings.show_heatmap && contributions && (
          <section id="activity" className="pb-11">
            <Heatmap days={contributions.days} total={contributions.total} activeDays={contributions.active_days} />
          </section>
        )}

        <Section id="interests" dot="green" title="What I'm into">
          <div className="grid grid-cols-[minmax(0,1fr)] gap-3.5 md:grid-cols-3">
            {INTERESTS.map(({ color, title, icon, body }) => (
              <div key={title} className={`panel p-[22px] transition-colors ${ACCENT[color].hover}`}>
                <div className={`mb-3.5 grid h-[34px] w-[34px] place-items-center rounded-[9px] ${ACCENT[color].icon}`}>
                  <svg className="h-[18px] w-[18px]" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">{icon}</svg>
                </div>
                <h3 className="mb-2 text-[17px] font-semibold">{title}</h3>
                <p className="text-[15px]">{body}</p>
              </div>
            ))}
          </div>
        </Section>

        <section className="grid grid-cols-[minmax(0,1fr)] gap-7 py-11 md:grid-cols-2 md:gap-12" style={{ '--dot': 'var(--c-violet)' }}>
          <div>
            <h2 className="section-title mb-5">How I like to work</h2>
            <div className="max-w-[680px] space-y-3.5 text-[17px]">
              <p>
                I value collaboration, learning and self-improvement. I do my best work on teams of talented, inclusive
                people who share ideas openly and push each other to do great work.
              </p>
              <p>
                I like understanding a problem all the way down before solving it, and I care about leaving code and
                systems in better shape than I found them.
              </p>
            </div>
          </div>
          <div>
            <h2 className="section-title mb-5">Off the clock</h2>
            <p className="text-[17px]">
              When I'm not at a keyboard you'll find me on a bike, on the slopes or on a basketball court. I also read a
              lot of graphic novels
              {graphicNovels && <> (<Link className="link" href={postLink(graphicNovels.slug)}>here are my favorites</Link>)</>}
              , play video games, and take fantasy sports far too seriously
              {fantasy && <> (<Link className="link" href={postLink(fantasy.slug)}>exhibit A</Link>)</>}.
            </p>
            <div className="mt-[18px] flex flex-wrap gap-2">
              {HOBBIES.map((h) => (
                <span key={h} className="rounded-full border border-line bg-panel px-3 py-1.5 text-sm">{h}</span>
              ))}
            </div>
          </div>
        </section>

        <Section id="work" dot="blue" title="Where I've worked">
          <div>
            {JOBS.map(({ company, role, years }) => (
              <div key={company} className="flex justify-between gap-4 border-b border-line py-3.5">
                <span>
                  <b className="font-semibold text-head">{company}</b> <span className="text-muted">· {role}</span>
                </span>
                <span className="font-mono text-[13px] whitespace-nowrap text-faint">{years}</span>
              </div>
            ))}
          </div>
          <p className="mt-3.5 text-sm text-muted">Earlier in my career I also worked at Casper, Stash and Chloe + Isabel.</p>
        </Section>

        {settings.show_writing && posts.length > 0 && (
          <Section id="writing" dot="amber" title="Writing">
            <div>
              {posts.map((post) => (
                <Link
                  key={post.slug}
                  href={postLink(post.slug)}
                  className="group grid grid-cols-[1fr_auto] items-baseline gap-x-4 border-b border-line px-1 py-3.5 transition-[padding] duration-200 hover:pl-2.5 md:grid-cols-[110px_1fr_auto]"
                >
                  <span className="col-span-2 font-mono text-xs text-faint md:col-span-1">{post.date}</span>
                  <span className="font-medium text-head group-hover:text-blue">{post.title}</span>
                  <span className="hidden text-[13px] text-faint md:inline">→</span>
                </Link>
              ))}
            </div>
          </Section>
        )}

        <section id="contact" className="scroll-mt-20 py-11">
          <div className="panel grid grid-cols-[minmax(0,1fr)] items-center gap-[30px] p-6 md:grid-cols-[1.2fr_1fr] md:p-[30px]">
            <div>
              <h2 className="text-2xl font-semibold tracking-tight">Let's talk</h2>
              <p className="mt-2">
                If you ever want to talk about programming, or would like to work together on something, please reach
                out. I'd love to hear from you.
              </p>
              <p className="mt-3 text-sm text-muted">Hiring? I'm happy to send over my resume.</p>
            </div>
            <div className="grid gap-2.5 font-mono">
              {[
                ['hillmandj@gmail.com', 'email', LINKS.email],
                ['github.com/hillmandj', 'code', LINKS.github],
                ['linkedin.com/in/hillmandj', 'work', LINKS.linkedin],
              ].map(([label, kind, href]) => (
                <a key={kind} href={href} className="flex justify-between rounded-[9px] border border-line px-3.5 py-3 text-sm text-head transition-colors hover:border-blue">
                  {label} <span className="text-xs text-faint">{kind}</span>
                </a>
              ))}
            </div>
          </div>
        </section>
      </div>
    </>
  )
}

Home.layout = (page) => <SiteLayout>{page}</SiteLayout>
