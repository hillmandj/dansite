import { Link, router, useForm } from '@inertiajs/react'
import { useCallback, useEffect, useLayoutEffect, useRef, useState } from 'react'
import SiteLayout from '../../../layouts/SiteLayout'
import Switch from '../../../components/Switch'
import { longDate } from '../../../lib/dates'

const csrfToken = () => document.querySelector('meta[name="csrf-token"]')?.content

// Reader widths: the post column is 700px with 24px padding on each side.
const WIDTHS = { desktop: 700, phone: 390 }

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

async function uploadImage(file) {
  const body = new FormData()
  body.append('image', file)
  const response = await fetch('/admin/images', {
    method: 'POST',
    headers: { Accept: 'application/json', 'X-CSRF-Token': csrfToken() },
    body,
  })
  const data = await response.json().catch(() => ({}))
  if (!response.ok) throw new Error(data.error || `Upload failed (HTTP ${response.status}).`)
  return data.url
}

const altFromFilename = (name) =>
  name.replace(/\.[^.]+$/, '').replace(/[-_]+/g, ' ').replace(/\s+/g, ' ').trim() || 'image'

// Labels every image in the preview with its real size and how wide it will
// actually appear, so it's obvious whether it fits.
function annotateImages(container) {
  if (!container) return
  container.querySelectorAll('[data-image-note]').forEach((n) => n.remove())
  container.querySelectorAll('img').forEach((img) => {
    const label = () => {
      if (!img.naturalWidth) return
      if (img.nextElementSibling?.hasAttribute('data-image-note')) img.nextElementSibling.remove()
      const shown = Math.round(img.getBoundingClientRect().width)
      const column = Math.round(img.parentElement.getBoundingClientRect().width)
      const small = img.naturalWidth < column
      const note = document.createElement('div')
      note.dataset.imageNote = ''
      note.className = `image-note${small ? ' image-note-warn' : ''}`
      note.textContent = small
        ? `${img.naturalWidth}×${img.naturalHeight} · narrower than the ${column}px column, shown at actual size`
        : `${img.naturalWidth}×${img.naturalHeight} · fits, shown at ${shown}px wide`
      img.insertAdjacentElement('afterend', note)
    }
    if (img.complete) label()
    else img.addEventListener('load', label, { once: true })
  })
}

function Preview({ title, html, width, framed }) {
  const ref = useRef(null)

  useLayoutEffect(() => {
    annotateImages(ref.current)
    const onResize = () => annotateImages(ref.current)
    window.addEventListener('resize', onResize)
    return () => window.removeEventListener('resize', onResize)
  }, [html, width])

  const today = new Date().toISOString().slice(0, 10)
  return (
    <div
      className={framed ? 'mx-auto overflow-hidden rounded-xl border border-line bg-bg' : ''}
      style={framed ? { width: WIDTHS[width], maxWidth: '100%' } : undefined}
    >
      <div className="px-6 pt-8 pb-10">
        {framed && (
          <>
            <h1 className="mb-3 text-[clamp(28px,5vw,40px)] leading-[1.1] font-bold tracking-[-.03em]">{title || 'Untitled'}</h1>
            <div className="mb-8 font-mono text-[13px] text-faint">{longDate(today)} · preview</div>
          </>
        )}
        <div ref={ref} className="post-body" dangerouslySetInnerHTML={{ __html: html }} />
      </div>
    </div>
  )
}

const MODES = [['write', 'Write'], ['split', 'Split'], ['preview', 'Preview']]

export default function PostForm({ post }) {
  const form = useForm({ title: post.title, content: post.content, published: post.published })
  const previewHtml = usePreview(form.data.content)
  const textarea = useRef(null)
  const fileInput = useRef(null)
  const [mode, setMode] = useState('split')
  const [width, setWidth] = useState('desktop')
  const [uploading, setUploading] = useState(0)
  const [uploadError, setUploadError] = useState(null)

  // Always edit the latest content (uploads finish after more typing).
  const contentRef = useRef(form.data.content)
  contentRef.current = form.data.content
  const setContent = useCallback((value) => form.setData('content', value), [form])

  const save = (e) => {
    e?.preventDefault()
    const options = { preserveScroll: true, onSuccess: () => form.setDefaults() }
    form.transform((data) => ({ post: data }))
    if (post.persisted) form.patch(`/admin/posts/${post.slug}`, options)
    else form.post('/admin/posts', options)
  }

  // Insert a placeholder at the cursor, upload, then swap in the real link.
  const insertImages = async (files) => {
    const images = [...files].filter((f) => f.type.startsWith('image/'))
    if (images.length === 0) return
    setUploadError(null)

    for (const file of images) {
      const token = `![Uploading ${file.name}…]()`
      const el = textarea.current
      const at = el ? el.selectionStart : contentRef.current.length
      const before = contentRef.current.slice(0, at)
      const pad = before && !before.endsWith('\n\n') ? (before.endsWith('\n') ? '\n' : '\n\n') : ''
      setContent(`${before}${pad}${token}\n\n${contentRef.current.slice(at)}`)

      setUploading((n) => n + 1)
      try {
        const url = await uploadImage(file)
        setContent(contentRef.current.replace(token, `![${altFromFilename(file.name)}](${url})`))
        if (mode === 'write') setMode('split')
      } catch (error) {
        setContent(contentRef.current.replace(`${token}\n\n`, '').replace(token, ''))
        setUploadError(`${file.name}: ${error.message}`)
      } finally {
        setUploading((n) => n - 1)
      }
    }
  }

  const onPaste = (e) => {
    if (e.clipboardData?.files?.length) { e.preventDefault(); insertImages(e.clipboardData.files) }
  }
  const onDrop = (e) => {
    if (e.dataTransfer?.files?.length) { e.preventDefault(); insertImages(e.dataTransfer.files) }
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

  const status = uploading
    ? `uploading ${uploading} image${uploading > 1 ? 's' : ''}…`
    : form.processing ? 'saving…' : form.isDirty ? 'unsaved changes' : post.persisted ? 'saved' : 'new post'

  const segment = (active) =>
    `cursor-pointer rounded-md px-3 py-1 transition-colors ${active ? 'bg-panel-2 text-head' : 'text-muted hover:text-head'}`

  const editor = (
    <div
      className="panel flex min-h-[560px] flex-col"
      onDragOver={(e) => e.preventDefault()}
      onDrop={onDrop}
    >
      <div className="flex items-center justify-between gap-3 border-b border-line-soft px-3.5 py-2 font-mono text-xs text-faint">
        <span>markdown · drop or paste images</span>
        <button type="button" onClick={() => fileInput.current?.click()} className="cursor-pointer rounded-md border border-line px-2.5 py-1 text-text hover:border-blue hover:text-blue">
          + Image
        </button>
        <input
          ref={fileInput}
          type="file"
          accept="image/jpeg,image/png,image/gif,image/webp,image/avif"
          multiple
          hidden
          onChange={(e) => { insertImages(e.target.files); e.target.value = '' }}
        />
      </div>
      <textarea
        ref={textarea}
        value={form.data.content}
        onChange={(e) => form.setData('content', e.target.value)}
        onPaste={onPaste}
        aria-label="Content (Markdown)"
        spellCheck
        className="min-h-[520px] flex-1 resize-y border-0 bg-transparent p-4 font-mono text-sm leading-7 text-text outline-none"
      />
    </div>
  )

  return (
    <form onSubmit={save} className="mx-auto max-w-[1100px] px-6 pt-10 pb-6">
      <div className="mb-6 flex flex-wrap items-center justify-between gap-4">
        <div className="font-mono text-[13px] text-muted">
          <Link href="/admin" className="text-blue">admin</Link> / {post.persisted ? 'edit' : 'new'}
        </div>
        <div className="flex flex-wrap items-center gap-3">
          <span className={`font-mono text-[13px] ${form.isDirty || uploading ? 'text-amber' : 'text-muted'}`}>{status}</span>
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
          <button type="submit" disabled={form.processing || uploading > 0} className="btn btn-primary cursor-pointer disabled:opacity-60">Save</button>
        </div>
      </div>

      <input
        value={form.data.title}
        onChange={(e) => form.setData('title', e.target.value)}
        placeholder="Title"
        aria-label="Title"
        className="mb-1 w-full border-0 border-b border-line bg-transparent pt-2 pb-3 text-[30px] font-bold tracking-tight text-head outline-none placeholder:text-faint focus:border-blue"
      />
      <div className="mb-3 min-h-5 text-sm text-red">
        {[form.errors.title, form.errors.content, form.errors.slug, uploadError].filter(Boolean).join(' · ')}
      </div>

      <div className="mb-4 flex flex-wrap items-center justify-between gap-3 font-mono text-[13px]">
        <div className="flex gap-1 rounded-lg border border-line bg-panel p-1" role="tablist" aria-label="Editor layout">
          {MODES.map(([key, label]) => (
            <button key={key} type="button" role="tab" aria-selected={mode === key} onClick={() => setMode(key)} className={segment(mode === key)}>{label}</button>
          ))}
        </div>
        {mode === 'preview' && (
          <div className="flex items-center gap-3">
            <span className="text-faint">exact reader width</span>
            <div className="flex gap-1 rounded-lg border border-line bg-panel p-1" role="tablist" aria-label="Preview width">
              {[['desktop', 'Desktop'], ['phone', 'Phone']].map(([key, label]) => (
                <button key={key} type="button" role="tab" aria-selected={width === key} onClick={() => setWidth(key)} className={segment(width === key)}>{label}</button>
              ))}
            </div>
          </div>
        )}
      </div>

      {mode === 'write' && editor}

      {mode === 'split' && (
        <div className="grid gap-4 lg:grid-cols-2">
          {editor}
          <div className="panel min-h-[560px] overflow-auto">
            <div className="border-b border-line-soft px-3.5 py-2.5 font-mono text-xs text-faint">preview · narrower than the real page; use Preview for exact widths</div>
            <div className="[&_.post-body]:text-base">
              <Preview title={form.data.title} html={previewHtml} width={width} framed={false} />
            </div>
          </div>
        </div>
      )}

      {mode === 'preview' && <Preview title={form.data.title} html={previewHtml} width={width} framed />}
    </form>
  )
}

PostForm.layout = (page) => <SiteLayout hideNav>{page}</SiteLayout>
