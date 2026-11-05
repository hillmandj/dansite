import { Link, router, usePage } from '@inertiajs/react'

// Thin amber strip shown on every page while the admin is signed in.
export default function AdminBar() {
  const { url, props } = usePage()
  const editing = props.post && url.startsWith('/blog/') && props.post.slug

  return (
    <div className="border-b border-line bg-[color-mix(in_srgb,var(--c-amber)_14%,var(--c-bg))] font-mono text-[13px]">
      <div className="wrap flex h-9 items-center justify-between gap-4 text-muted">
        <span>signed in as admin</span>
        <span className="flex gap-4">
          {editing && <Link className="text-blue" href={`/admin/posts/${props.post.slug}/edit`}>edit post</Link>}
          <Link className="text-blue" href="/">view site</Link>
          <Link className="text-blue" href="/admin">admin</Link>
          <Link className="text-blue" href="/admin/account/edit">account</Link>
          <button type="button" className="cursor-pointer text-blue" onClick={() => router.delete('/users/sign_out')}>log out</button>
        </span>
      </div>
    </div>
  )
}
