import { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext'

export function LoginPage() {
  const navigate = useNavigate()
  const { login, isReady, error, isAuthenticated } = useAuth()

  useEffect(() => {
    if (isAuthenticated) {
      navigate('/', { replace: true })
    }
  }, [isAuthenticated, navigate])

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-100 px-6">
      <div className="max-w-md rounded-2xl border border-slate-200 bg-white p-8 text-center shadow-sm">
        <h1 className="text-2xl font-semibold text-slate-900">Bem-vindo à Hypesoft</h1>
        <p className="mt-2 text-sm text-slate-500">
          Faça login para acessar o sistema de gestão de produtos.
        </p>
        <button
          onClick={login}
          className="mt-6 w-full rounded-full bg-indigo-600 px-4 py-2 text-sm font-semibold text-white transition hover:bg-indigo-500 disabled:cursor-not-allowed disabled:opacity-60"
          disabled={!isReady}
        >
          {isReady ? 'Entrar com Keycloak' : 'Conectando ao Keycloak...'}
        </button>
        {error && (
          <p className="mt-4 text-xs text-rose-500">
            {error}
          </p>
        )}
      </div>
    </div>
  )
}
