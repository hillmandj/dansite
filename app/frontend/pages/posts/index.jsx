import { Link } from '@inertiajs/react'
import SiteLayout from '../../layouts/SiteLayout'
import PostList from '../../components/PostList'

export default function PostsIndex({ posts, page, total_pages: totalPages }) {
  const pageUrl = (n) => (n > 1 ? `/blog?page=${n}` : '/blog')

  return (
    <div className="wrap max-w-[760px] pt-16 pb-6" style={{ '--dot': 'var(--c-amber)' }}>
      <h1 className="section-title mb-2 text-[clamp(30px,4.5vw,42px)]! font-bold">Writing</h1>
      <p className="mb-8 text-muted">Occasional posts about code and everything else.</p>
      {posts.length > 0 ? <PostList posts={posts} /> : <p className="text-muted">Nothing here yet.</p>}

      {totalPages > 1 && (
        <nav className="mt-8 flex items-center justify-between font-mono text-[13px]" aria-label="Pages">
          {page > 1 ? <Link href={pageUrl(page - 1)} className="text-blue hover:underline">← Newer posts</Link> : <span />}
          <span className="text-faint">page {page} of {totalPages}</span>
          {page < totalPages ? <Link href={pageUrl(page + 1)} className="text-blue hover:underline">Older posts →</Link> : <span />}
        </nav>
      )}
    </div>
  )
}

PostsIndex.layout = (page) => <SiteLayout>{page}</SiteLayout>
