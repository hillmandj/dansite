import { Link, router, usePage } from '@inertiajs/react'
import { useState } from 'react'
import SiteLayout from '../../../layouts/SiteLayout'
import Switch from '../../../components/Switch'

const SETTINGS = [
  ['show_heatmap', 'GitHub activity', "Show the contribution heatmap on the home page. Turn off while you're on vacation."],
  ['show_writing', 'Writing section', 'List recent posts on the home page.'],
]

export default function AdminPosts({ posts, settings: initialSettings, themes }) {
  const [settings, setSettings] = useState(initialSettings)
  const siteTheme = usePage().props.site_theme

  // Saved right away; every page (this one included) switches to the new theme.
  const changeTheme = (value) => {
    router.patch('/admin/settings', { settings: { site_theme: value } }, { preserveScroll: true, preserveState: true })
  }

  const toggleSetting = (key, value) => {
    const next = { ...settings, [key]: value }
    setSettings(next)
    router.patch('/admin/settings', { settings: { [key]: value } }, {
      preserveScroll: true,
      preserveState: true,
      onError: () => setSettings(settings),
    })
  }

  const destroy = (post) => {
    if (window.confirm(`Delete “${post.title}”? This can't be undone.`)) {
      router.delete(`/admin/posts/${post.slug}`, { preserveScroll: true })
    }
  }

  return (
    <div className="mx-auto max-w-[1100px] px-6 pt-10 pb-6">
      <div className="mb-6 flex flex-wrap items-center justify-between gap-4">
        <div>
          <div className="mb-1 font-mono text-[13px] text-muted">admin</div>
          <h1 className="text-3xl font-bold tracking-tight">Posts</h1>
        </div>
        <Link href="/admin/posts/new" className="btn btn-primary">+ New post</Link>
      </div>

      <div className="grid items-start gap-5 lg:grid-cols-[minmax(0,1fr)_320px]">
        <div className="panel overflow-x-auto">
          <table className="w-full border-collapse text-[15px]">
            <thead>
              <tr className="border-b border-line text-left font-mono text-xs text-faint">
                <th className="px-[18px] py-3.5 font-medium">title</th>
                <th className="px-[18px] py-3.5 font-medium">status</th>
                <th className="hidden px-[18px] py-3.5 font-medium sm:table-cell">updated</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {posts.map((post) => (
                <tr key={post.slug} className="border-b border-line-soft last:border-0">
                  <td className="px-[18px] py-3.5 font-medium text-head">
                    <Link href={`/admin/posts/${post.slug}/edit`} className="hover:text-link">{post.title}</Link>
                  </td>
                  <td className="px-[18px] py-3.5">
                    <span className={`rounded-full px-2 py-0.5 font-mono text-[11px] font-semibold ${
                      post.published ? 'bg-green/15 text-green' : 'bg-amber/15 text-amber'
                    }`}>
                      {post.published ? 'published' : 'draft'}
                    </span>
                  </td>
                  <td className="hidden px-[18px] py-3.5 text-[13px] whitespace-nowrap text-muted sm:table-cell">{post.updated}</td>
                  <td className="px-[18px] py-3.5 text-right text-[13px] whitespace-nowrap">
                    <Link href={`/admin/posts/${post.slug}/edit`} className="ml-3.5 text-link">edit</Link>
                    <Link href={`/blog/${post.slug}`} className="ml-3.5 text-link">view</Link>
                    <button type="button" onClick={() => destroy(post)} className="ml-3.5 cursor-pointer text-red">delete</button>
                  </td>
                </tr>
              ))}
              {posts.length === 0 && (
                <tr><td colSpan={4} className="px-[18px] py-8 text-center text-muted">No posts yet.</td></tr>
              )}
            </tbody>
          </table>
        </div>

        <aside className="panel p-5">
          <h2 className="mb-1 text-[17px] font-semibold">Site settings</h2>
          <p className="mb-3.5 text-[13px] text-muted">Changes apply immediately. No deploy needed.</p>
          {SETTINGS.map(([key, title, hint]) => (
            <label key={key} className="flex cursor-pointer items-start justify-between gap-3.5 border-t border-line-soft py-3.5">
              <span>
                <b className="block text-[15px] font-medium text-head">{title}</b>
                <span className="text-[13px] text-muted">{hint}</span>
              </span>
              <Switch label={title} checked={settings[key]} onChange={(v) => toggleSetting(key, v)} />
            </label>
          ))}
          <label className="grid gap-2 border-t border-line-soft pt-3.5">
            <span>
              <b className="block text-[15px] font-medium text-head">Site theme</b>
              <span className="text-[13px] text-muted">Colors and style for every visitor. Each one has a light and dark mode.</span>
            </span>
            <select
              value={siteTheme}
              onChange={(e) => changeTheme(e.target.value)}
              className="w-full cursor-pointer rounded-control border border-line bg-panel-2 px-3 py-2 text-sm text-head outline-none focus:border-link"
            >
              {themes.map(({ key, label }) => <option key={key} value={key}>{label}</option>)}
            </select>
          </label>
        </aside>
      </div>
    </div>
  )
}

AdminPosts.layout = (page) => <SiteLayout hideNav>{page}</SiteLayout>
