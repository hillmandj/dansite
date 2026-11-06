import { Link } from '@inertiajs/react'

// `numbered` adds a line-number gutter in the terminal themes; `start` is the first number.
export default function PostList({ posts, numbered = false, start = 1 }) {
  return (
    <div>
      {posts.map((post, i) => (
        <Link
          key={post.slug}
          href={`/blog/${post.slug}`}
          className={`group grid grid-cols-[1fr_auto] items-baseline gap-x-4 border-b border-line px-1 py-3.5 transition-[padding] duration-200 hover:pl-2.5 md:grid-cols-[110px_1fr_auto] term:border-line-soft ${
            numbered ? 'term:grid-cols-[28px_1fr_auto] term:px-0 term:hover:pl-0 term:md:grid-cols-[28px_110px_1fr_auto]' : ''
          }`}
        >
          {numbered && (
            <span className="row-span-2 hidden text-right font-mono text-[13px] text-faint group-hover:text-fill term:block md:row-span-1">{start + i}</span>
          )}
          <span className="col-span-2 font-mono text-xs text-faint md:col-span-1">{post.date}</span>
          <span className="font-medium text-head group-hover:text-link term:group-hover:text-fill">{post.title}</span>
          <span className="hidden text-[13px] text-faint md:inline">→</span>
        </Link>
      ))}
    </div>
  )
}
