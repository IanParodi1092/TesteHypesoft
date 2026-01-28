import { useEffect, useState } from 'react'

export function SettingsPage() {
  const [theme, setTheme] = useState<'light' | 'dark'>(() => {
    if (typeof window === 'undefined') {
      return 'light'
    }
    return (localStorage.getItem('theme') as 'light' | 'dark') ?? 'light'
  })

  useEffect(() => {
    const root = document.documentElement
    if (theme === 'dark') {
      root.classList.add('dark')
    } else {
      root.classList.remove('dark')
    }
    localStorage.setItem('theme', theme)
  }, [theme])

  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
      <h2 className="text-lg font-semibold text-slate-900">Configurações</h2>
      <p className="mt-2 text-sm text-slate-500">
        Centralize ajustes do aplicativo, preferências de usuário e integrações.
      </p>

      <div className="mt-6 flex items-center justify-between rounded-xl border border-slate-200 bg-slate-50 px-4 py-3">
        <div>
          <p className="text-sm font-medium text-slate-900">Tema</p>
          <p className="text-xs text-slate-500">Escolha entre modo claro ou escuro.</p>
        </div>
        <button
          onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
          className="rounded-full border border-slate-200 bg-white px-3 py-1 text-xs text-slate-600"
        >
          {theme === 'dark' ? 'Modo claro' : 'Modo escuro'}
        </button>
      </div>
    </div>
  )
}
