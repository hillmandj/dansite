// Accessible on/off switch (a styled checkbox).
export default function Switch({ checked, onChange, label, disabled = false }) {
  return (
    <span className="relative inline-flex h-[22px] w-10 flex-none">
      <input
        type="checkbox"
        role="switch"
        aria-label={label}
        checked={checked}
        disabled={disabled}
        onChange={(e) => onChange(e.target.checked)}
        className="peer absolute inset-0 z-10 cursor-pointer opacity-0"
      />
      <span className="absolute inset-0 rounded-full bg-line transition-colors peer-checked:bg-green peer-focus-visible:ring-2 peer-focus-visible:ring-blue" />
      <span className="absolute top-[3px] left-[3px] h-4 w-4 rounded-full bg-white shadow transition-transform peer-checked:translate-x-[18px]" />
    </span>
  )
}
