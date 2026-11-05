import { Link } from '@inertiajs/react'
import SiteLayout from '../../layouts/SiteLayout'
import { longDate } from '../../lib/dates'

export default function PostShow({ post, older, newer }) {
  return (
    <>
      <article className="mx-auto max-w-[700px] px-6 pt-16 pb-10">
        <Link href="/blog" className="font-mono text-[13px] text-muted hover:text-blue">← all writing</Link>

        {post.draft && (
          <p className="mt-6 rounded-lg border border-amber/40 bg-amber/10 px-4 py-2.5 font-mono text-[13px] text-amber">
            Draft: only you can see this page.
          </p>
        )}

        <h1 className="mt-5 mb-3.5 text-[clamp(32px,5vw,46px)] leading-[1.1] font-bold tracking-[-.03em]">{post.title}</h1>
        <div className="flex flex-wrap gap-3.5 font-mono text-[13px] text-faint">
          <span>{longDate(post.date)}</span>
          <span>·</span>
          <span>{post.reading_minutes} min read</span>
        </div>

        {/* Server-rendered from Markdown and sanitized (see app/models/markdown.rb). */}
        <div className="post-body mt-10" dangerouslySetInnerHTML={{ __html: post.html }} />
      </article>

      {(older || newer) && (
        <nav className="mx-auto flex max-w-[700px] flex-wrap justify-between gap-4 border-t border-line px-6 pt-6 text-sm" aria-label="More posts">
          {older ? (
            <Link href={`/blog/${older.slug}`} className="group">
              <span className="block text-xs text-faint">← older</span>
              <b className="font-medium text-head group-hover:text-blue">{older.title}</b>
            </Link>
          ) : <span />}
          {newer && (
            <Link href={`/blog/${newer.slug}`} className="group text-right">
              <span className="block text-xs text-faint">newer →</span>
              <b className="font-medium text-head group-hover:text-blue">{newer.title}</b>
            </Link>
          )}
        </nav>
      )}
    </>
  )
}

PostShow.layout = (page) => <SiteLayout>{page}</SiteLayout>
