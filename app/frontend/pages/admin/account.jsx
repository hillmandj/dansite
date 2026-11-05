import { useForm } from '@inertiajs/react'
import SiteLayout from '../../layouts/SiteLayout'

const input = 'w-full rounded-[9px] border border-line bg-panel px-3.5 py-2.5 text-head outline-none transition-colors focus:border-blue'

const FIELDS = [
  ['current_password', 'Current password', 'current-password'],
  ['password', 'New password (8+ characters)', 'new-password'],
  ['password_confirmation', 'Confirm new password', 'new-password'],
]

export default function Account({ email }) {
  const form = useForm({ current_password: '', password: '', password_confirmation: '' })

  const submit = (e) => {
    e.preventDefault()
    form.transform((data) => ({ account: data }))
    form.patch('/admin/account', { onFinish: () => form.reset() })
  }

  return (
    <div className="mx-auto max-w-[460px] px-6 pt-14 pb-6">
      <div className="mb-1 font-mono text-[13px] text-muted">admin</div>
      <h1 className="mb-1.5 text-3xl font-bold tracking-tight">Account</h1>
      <p className="mb-8 text-sm text-muted">Signed in as {email}</p>

      <form onSubmit={submit} className="panel grid gap-4 p-6">
        <h2 className="text-[17px] font-semibold">Change password</h2>
        {FIELDS.map(([key, label, autoComplete]) => (
          <label key={key} className="grid gap-1.5 text-sm">
            <span className="text-muted">{label}</span>
            <input className={input} type="password" autoComplete={autoComplete} required
              value={form.data[key]} onChange={(e) => form.setData(key, e.target.value)} />
            {form.errors[key] && <span className="text-red">{form.errors[key]}</span>}
          </label>
        ))}
        <button type="submit" disabled={form.processing} className="btn btn-primary cursor-pointer justify-center disabled:opacity-60">
          Update password
        </button>
      </form>
    </div>
  )
}

Account.layout = (page) => <SiteLayout hideNav>{page}</SiteLayout>
