import { useAuth } from '../auth/AuthContext'

export function Topbar() {
  const { logout, userName } = useAuth()
  const initials = userName
    ? userName
        .split(' ')
        .filter(Boolean)
        .slice(0, 2)
        .map((part) => part[0])
        .join('')
        .toUpperCase()
    : 'US'

  return (
    <header className="flex flex-wrap items-center justify-between gap-4 border-b border-slate-200 bg-white px-8 py-5">
      <div>
        <h1 className="text-2xl font-semibold text-slate-900">Dashboard</h1>
        <p className="text-sm text-slate-500">Resumo de performance</p>
      </div>
      <div className="flex flex-1 items-center justify-end gap-4">
        <div className="flex items-center gap-3 rounded-full border border-slate-200 bg-white px-3 py-2 shadow-sm">
          <div className="flex h-9 w-9 items-center justify-center rounded-full bg-slate-200 text-xs font-semibold text-slate-700">
            {initials}
          </div>
          <div className="hidden text-sm text-slate-600 md:block">
            {userName ?? 'Minha conta'}
          </div>
          <button
            onClick={logout}
            className="rounded-full bg-slate-900 px-3 py-1 text-xs font-semibold text-white"
          >
            Sair
          </button>
        </div>
      </div>
    </header>
  )
}
