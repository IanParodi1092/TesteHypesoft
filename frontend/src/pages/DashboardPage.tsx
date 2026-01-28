import { useQuery } from '@tanstack/react-query'
import { getDashboard } from '../services/dashboard'
import { StatCard } from '../components/StatCard'
import { useAuth } from '../auth/AuthContext'
import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts'

export function DashboardPage() {
  const { isAuthenticated } = useAuth()
  const { data, isLoading, isError } = useQuery({
    queryKey: ['dashboard'],
    queryFn: getDashboard,
    enabled: isAuthenticated,
  })

  if (isError) {
    return <div className="text-rose-400">Não foi possível carregar o dashboard.</div>
  }

  if (isLoading || !data) {
    return <div className="text-slate-400">Carregando dashboard...</div>
  }

  return (
    <div className="space-y-8">
      <section className="grid gap-6 lg:grid-cols-3">
        <StatCard
          label="Produtos cadastrados"
          value={data.totalProducts.toString()}
          helper="Total de itens registrados"
        />
        <StatCard
          label="Valor em estoque"
          value={new Intl.NumberFormat('pt-BR', {
            style: 'currency',
            currency: 'BRL',
          }).format(data.totalStockValue)}
          helper="Soma de preço x quantidade"
        />
        <StatCard
          label="Estoque baixo"
          value={data.lowStockProducts.length.toString()}
          helper="Produtos com menos de 10 unidades"
        />
      </section>

      <section className="grid gap-6 lg:grid-cols-[2fr_1fr]">
        <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-lg font-semibold text-slate-900">Produtos por categoria</h2>
              <p className="text-sm text-slate-500">Visão geral do catálogo</p>
            </div>
            <button className="rounded-full border border-slate-200 px-3 py-1 text-xs text-slate-500">
              Filtrar
            </button>
          </div>
          <div className="mt-6 h-64">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data.productsByCategory} margin={{ left: 0, right: 16 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                <XAxis dataKey="categoryName" stroke="#94a3b8" fontSize={12} />
                <YAxis stroke="#94a3b8" fontSize={12} allowDecimals={false} />
                <Tooltip
                  contentStyle={{
                    background: '#ffffff',
                    border: '1px solid #e2e8f0',
                    color: '#0f172a',
                  }}
                />
                <Bar dataKey="count" fill="#6366f1" radius={[10, 10, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-slate-900">Estoque baixo</h2>
          <p className="text-sm text-slate-500">Itens que precisam de reposição</p>

          <div className="mt-5 space-y-4">
            {data.lowStockProducts.length === 0 ? (
              <p className="text-sm text-slate-500">Nenhum produto com estoque baixo.</p>
            ) : (
              data.lowStockProducts.map((product) => (
                <div
                  key={product.id}
                  className="rounded-xl border border-slate-200 bg-slate-50 px-4 py-3"
                >
                  <div className="text-sm font-medium text-slate-900">{product.name}</div>
                  <div className="text-xs text-slate-500">
                    {product.categoryName ?? 'Sem categoria'} • {product.quantity} unidades
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </section>
    </div>
  )
}
