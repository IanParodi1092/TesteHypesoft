type StatCardProps = {
  label: string
  value: string
  helper?: string
}

export function StatCard({ label, value, helper }: StatCardProps) {
  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
      <p className="text-xs font-semibold uppercase tracking-[0.2em] text-slate-400">{label}</p>
      <div className="mt-3 text-3xl font-semibold text-slate-900">{value}</div>
      {helper && <p className="mt-2 text-xs text-slate-500">{helper}</p>}
    </div>
  )
}
