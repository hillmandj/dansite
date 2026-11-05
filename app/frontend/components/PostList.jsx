import { Link } from '@inertiajs/react'

export default function PostList({ posts }) {
  return (
    <div>
      {posts.map((post) => (
        <Link
          key={post.slug}
          href={`/blog/${post.slug}`}
          className="group grid grid-cols-[1fr_auto] items-baseline gap-x-4 border-b border-line px-1 py-3.5 transition-[padding] duration-200 hover:pl-2.5 md:grid-cols-[110px_1fr_auto]"
        >
          <span className="col-span-2 font-mono text-xs text-faint md:col-span-1">{post.date}</span>
          <span className="font-medium text-head group-hover:text-blue">{post.title}</span>
          <span className="hidden text-[13px] text-faint md:inline">→</span>
        </Link>
      ))}
    </div>
  )
}
