import { NavLink } from 'react-router-dom'

const navItems = {
  general: [
    { label: 'Dashboard', to: '/' },
    { label: 'Estatísticas', to: '/' },
  ],
  shop: [
    { label: 'Produtos', to: '/produtos' },
    { label: 'Categorias', to: '/categorias' },
  ],
  support: [
    { label: 'Configurações', to: '/configuracoes' },
    { label: 'Ajuda', to: '/ajuda' },
  ],
}

export function Sidebar() {
  return (
    <aside className="flex h-full w-64 flex-col border-r border-slate-200 bg-white px-6 py-8">
      <div className="flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-indigo-600 text-white">
          HS
        </div>
        <div>
          <div className="text-lg font-semibold text-slate-900">ShopSense</div>
          <p className="text-xs text-slate-500">Gestão de produtos</p>
        </div>
      </div>

      <nav className="mt-8 space-y-6">
        <div>
          <p className="text-[11px] font-semibold uppercase tracking-[0.2em] text-slate-400">Geral</p>
          <div className="mt-3 flex flex-col gap-2">
            {navItems.general.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                className={({ isActive }) =>
                  `rounded-xl px-4 py-2 text-sm font-medium transition ${
                    isActive
                      ? 'bg-slate-100 text-slate-900'
                      : 'text-slate-500 hover:bg-slate-100 hover:text-slate-900'
                  }`
                }
              >
                {item.label}
              </NavLink>
            ))}
          </div>
        </div>

        <div>
          <p className="text-[11px] font-semibold uppercase tracking-[0.2em] text-slate-400">Loja</p>
          <div className="mt-3 flex flex-col gap-2">
            {navItems.shop.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                className={({ isActive }) =>
                  `rounded-xl px-4 py-2 text-sm font-medium transition ${
                    isActive
                      ? 'bg-slate-100 text-slate-900'
                      : 'text-slate-500 hover:bg-slate-100 hover:text-slate-900'
                  }`
                }
              >
                {item.label}
              </NavLink>
            ))}
          </div>
        </div>

        <div>
          <p className="text-[11px] font-semibold uppercase tracking-[0.2em] text-slate-400">Suporte</p>
          <div className="mt-3 flex flex-col gap-2">
            {navItems.support.map((item) => (
              <NavLink
                key={item.label}
                to={item.to}
                className="rounded-xl px-4 py-2 text-sm font-medium text-slate-500 transition hover:bg-slate-100 hover:text-slate-900"
              >
                {item.label}
              </NavLink>
            ))}
          </div>
        </div>
      </nav>
    </aside>
  )
}
