import { useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { createCategory, deleteCategory, listCategories } from '../services/categories'
import { useAuth } from '../auth/AuthContext'

export function CategoriesPage() {
  const { isAuthenticated } = useAuth()
  const [name, setName] = useState('')
  const queryClient = useQueryClient()

  const { data, isLoading, isError } = useQuery({
    queryKey: ['categories'],
    queryFn: listCategories,
    enabled: isAuthenticated,
  })

  const createMutation = useMutation({
    mutationFn: createCategory,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['categories'] })
      setName('')
    },
  })

  const deleteMutation = useMutation({
    mutationFn: deleteCategory,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['categories'] })
    },
  })

  return (
    <div className="grid gap-8 lg:grid-cols-[2fr_1fr]">
      <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
        <div>
          <h2 className="text-lg font-semibold text-slate-900">Categorias</h2>
          <p className="text-sm text-slate-500">Organize o catálogo</p>
        </div>

        <div className="mt-6 space-y-3">
          {isError && (
            <p className="text-sm text-rose-500">Não foi possível carregar categorias.</p>
          )}
          {isLoading ? (
            <p className="text-sm text-slate-400">Carregando categorias...</p>
          ) : data?.length ? (
            data.map((category) => (
              <div
                key={category.id}
                className="flex items-center justify-between rounded-xl border border-slate-200 bg-slate-50 px-4 py-3"
              >
                <div className="text-sm text-slate-800">{category.name}</div>
                <button
                  onClick={() => deleteMutation.mutate(category.id)}
                  className="text-xs font-medium text-rose-500 hover:text-rose-400"
                >
                  Excluir
                </button>
              </div>
            ))
          ) : (
            <p className="text-sm text-slate-400">Nenhuma categoria cadastrada.</p>
          )}
        </div>
      </section>

      <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
        <h2 className="text-lg font-semibold text-slate-900">Nova categoria</h2>
        <p className="text-sm text-slate-500">Crie novas categorias</p>

        <div className="mt-6 space-y-4">
          <div>
            <label className="text-xs text-slate-500">Nome</label>
            <input
              value={name}
              onChange={(event) => setName(event.target.value)}
              className="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700"
            />
          </div>
          <button
            onClick={() => createMutation.mutate(name)}
            className="w-full rounded-full bg-indigo-600 px-4 py-2 text-sm font-semibold text-white transition hover:bg-indigo-500"
            disabled={!name || createMutation.isPending}
          >
            Criar categoria
          </button>
        </div>
      </section>
    </div>
  )
}
