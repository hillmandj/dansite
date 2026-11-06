import { useForm } from '@inertiajs/react'
import SiteLayout from '../../layouts/SiteLayout'

const input = 'w-full rounded-control border border-line bg-panel px-3.5 py-2.5 text-head outline-none transition-colors focus:border-link'

export default function Login() {
  const form = useForm({ user: { email: '', password: '', remember_me: false } })
  const set = (key, value) => form.setData('user', { ...form.data.user, [key]: value })

  const submit = (e) => {
    e.preventDefault()
    form.post('/users/sign_in', { onFinish: () => set('password', '') })
  }

  return (
    <div className="mx-auto max-w-[400px] px-6 pt-20 pb-10">
      <h1 className="mb-1.5 text-3xl font-bold tracking-tight">Log in</h1>
      <p className="mb-8 font-mono text-[13px] text-faint">admin only</p>

      <form onSubmit={submit} className="panel grid gap-4 p-6">
        {form.errors.email && (
          <p className="rounded-lg border border-red/40 bg-red/10 px-3 py-2 text-sm text-red">{form.errors.email}</p>
        )}
        <label className="grid gap-1.5 text-sm">
          <span className="text-muted">Email</span>
          <input className={input} type="email" autoComplete="username" required autoFocus
            value={form.data.user.email} onChange={(e) => set('email', e.target.value)} />
        </label>
        <label className="grid gap-1.5 text-sm">
          <span className="text-muted">Password</span>
          <input className={input} type="password" autoComplete="current-password" required
            value={form.data.user.password} onChange={(e) => set('password', e.target.value)} />
        </label>
        <label className="flex items-center gap-2 text-sm text-muted">
          <input type="checkbox" checked={form.data.user.remember_me} onChange={(e) => set('remember_me', e.target.checked)} />
          Remember me
        </label>
        <button type="submit" disabled={form.processing} className="btn btn-primary justify-center disabled:opacity-60">
          {form.processing ? 'Logging in…' : 'Log in'}
        </button>
      </form>
    </div>
  )
}

Login.layout = (page) => <SiteLayout hideNav>{page}</SiteLayout>
