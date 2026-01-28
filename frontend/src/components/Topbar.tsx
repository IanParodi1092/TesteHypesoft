import { useAuth } from '../auth/AuthContext'

export function Topbar() {
  const { logout } = useAuth()

  return (
    <header className="flex flex-wrap items-center justify-between gap-4 border-b border-slate-200 bg-white px-8 py-5">
      <div>
        <h1 className="text-2xl font-semibold text-slate-900">Dashboard</h1>
        <p className="text-sm text-slate-500">Resumo de performance</p>
      </div>
      <div className="flex flex-1 items-center justify-end gap-4">
        <div className="hidden items-center gap-2 rounded-full border border-slate-200 bg-slate-50 px-4 py-2 text-sm text-slate-500 lg:flex">
          <span>Pesquisar</span>
          <span className="text-xs text-slate-400">⌘K</span>
        </div>
        <button className="rounded-full border border-slate-200 bg-white px-4 py-2 text-sm text-slate-600 shadow-sm">
          May 6 - Jun 6
        </button>
        <div className="flex items-center gap-3 rounded-full border border-slate-200 bg-white px-3 py-2 shadow-sm">
          <div className="flex h-9 w-9 items-center justify-center rounded-full bg-slate-200 text-xs font-semibold text-slate-700">
            MS
          </div>
          <div className="hidden text-sm text-slate-600 md:block">
            Miguel Santos
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
