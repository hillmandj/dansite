import { Link, router, useForm } from '@inertiajs/react'
import { useEffect, useRef, useState } from 'react'
import SiteLayout from '../../../layouts/SiteLayout'
import Switch from '../../../components/Switch'

const csrfToken = () => document.querySelector('meta[name="csrf-token"]')?.content

// Renders Markdown on the server (same renderer and sanitizer as the live
// site), debounced while typing.
function usePreview(content) {
  const [html, setHtml] = useState('')

  useEffect(() => {
    const controller = new AbortController()
    const timer = setTimeout(async () => {
      try {
        const response = await fetch('/admin/preview', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', Accept: 'application/json', 'X-CSRF-Token': csrfToken() },
          body: JSON.stringify({ content }),
          signal: controller.signal,
        })
        if (response.ok) setHtml((await response.json()).html)
      } catch {
        /* aborted or offline: keep the last preview */
      }
    }, 250)
    return () => { clearTimeout(timer); controller.abort() }
  }, [content])

  return html
}

export default function PostForm({ post }) {
  const form = useForm({ title: post.title, content: post.content, published: post.published })
  const previewHtml = usePreview(form.data.content)
  const textarea = useRef(null)

  const save = (e) => {
    e?.preventDefault()
    const options = { preserveScroll: true, onSuccess: () => form.setDefaults() }
    form.transform((data) => ({ post: data }))
    if (post.persisted) form.patch(`/admin/posts/${post.slug}`, options)
    else form.post('/admin/posts', options)
  }

  // Cmd/Ctrl+S saves.
  useEffect(() => {
    const onKey = (e) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 's') { e.preventDefault(); save() }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  })

  // Warn before leaving with unsaved changes.
  useEffect(() => {
    if (!form.isDirty) return
    const onBeforeUnload = (e) => { e.preventDefault() }
    const removeRouterGuard = router.on('before', (event) => {
      const leaving = event.detail.visit.method === 'get'
      return !leaving || window.confirm('You have unsaved changes. Leave anyway?')
    })
    window.addEventListener('beforeunload', onBeforeUnload)
    return () => { window.removeEventListener('beforeunload', onBeforeUnload); removeRouterGuard() }
  }, [form.isDirty])

  const destroy = () => {
    if (window.confirm(`Delete “${post.title}”? This can't be undone.`)) {
      form.reset()
      router.delete(`/admin/posts/${post.slug}`)
    }
  }

  const status = form.processing ? 'saving…' : form.isDirty ? 'unsaved changes' : post.persisted ? 'saved' : 'new post'

  return (
    <form onSubmit={save} className="mx-auto max-w-[1100px] px-6 pt-10 pb-6">
      <div className="mb-6 flex flex-wrap items-center justify-between gap-4">
        <div className="font-mono text-[13px] text-muted">
          <Link href="/admin" className="text-blue">admin / posts</Link> / {post.persisted ? 'edit' : 'new'}
        </div>
        <div className="flex flex-wrap items-center gap-3">
          <span className={`font-mono text-[13px] ${form.isDirty ? 'text-amber' : 'text-muted'}`}>{status}</span>
          <label className="flex cursor-pointer items-center gap-2.5 text-sm">
            <Switch label="Published" checked={form.data.published} onChange={(v) => form.setData('published', v)} />
            <span className="w-[72px]">{form.data.published ? 'Published' : 'Draft'}</span>
          </label>
          {post.persisted && (
            <>
              <Link href={`/blog/${post.slug}`} className="btn">View</Link>
              <button type="button" onClick={destroy} className="btn cursor-pointer hover:border-red! hover:text-red">Delete</button>
            </>
          )}
          <button type="submit" disabled={form.processing} className="btn btn-primary cursor-pointer disabled:opacity-60">Save</button>
        </div>
      </div>

      <input
        value={form.data.title}
        onChange={(e) => form.setData('title', e.target.value)}
        placeholder="Title"
        aria-label="Title"
        className="mb-1 w-full border-0 border-b border-line bg-transparent pt-2 pb-3 text-[30px] font-bold tracking-tight text-head outline-none placeholder:text-faint focus:border-blue"
      />
      <div className="mb-4 min-h-5 text-sm text-red">
        {[form.errors.title, form.errors.content, form.errors.slug].filter(Boolean).join(' · ')}
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <div className="panel flex min-h-[540px] flex-col">
          <div className="flex justify-between border-b border-line-soft px-3.5 py-2.5 font-mono text-xs text-faint">
            <span>markdown</span><span>html allowed for video</span>
          </div>
          <textarea
            ref={textarea}
            value={form.data.content}
            onChange={(e) => form.setData('content', e.target.value)}
            aria-label="Content (Markdown)"
            spellCheck
            className="min-h-[500px] flex-1 resize-y border-0 bg-transparent p-4 font-mono text-sm leading-7 text-text outline-none"
          />
        </div>
        <div className="panel flex min-h-[540px] flex-col">
          <div className="flex justify-between border-b border-line-soft px-3.5 py-2.5 font-mono text-xs text-faint">
            <span>preview</span><span>live</span>
          </div>
          <div className="post-body overflow-auto px-6 py-5 text-base!" dangerouslySetInnerHTML={{ __html: previewHtml }} />
        </div>
      </div>
    </form>
  )
}

PostForm.layout = (page) => <SiteLayout hideNav>{page}</SiteLayout>
