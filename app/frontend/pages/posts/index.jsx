import SiteLayout from '../../layouts/SiteLayout'
import PostList from '../../components/PostList'

export default function PostsIndex({ posts }) {
  return (
    <div className="wrap max-w-[760px] pt-16 pb-6" style={{ '--dot': 'var(--c-amber)' }}>
      <h1 className="section-title mb-2 text-[clamp(30px,4.5vw,42px)]! font-bold">Writing</h1>
      <p className="mb-8 text-muted">Occasional posts about code and everything else.</p>
      {posts.length > 0 ? <PostList posts={posts} /> : <p className="text-muted">Nothing here yet.</p>}
    </div>
  )
}

PostsIndex.layout = (page) => <SiteLayout>{page}</SiteLayout>
