import { useEffect, useState } from 'react'
import { useForm } from 'react-hook-form'
import type { Resolver, SubmitHandler } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { z } from 'zod'
import {
  createProduct,
  deleteProduct,
  listProducts,
  updateProduct,
  updateProductStock,
} from '../services/products'
import { listCategories } from '../services/categories'
import type { Product } from '../types'
import { formatCurrency } from '../lib/format'
import { useAuth } from '../auth/AuthContext'

const productSchema = z.object({
  id: z.string().optional(),
  name: z.string().min(1, 'Informe o nome'),
  description: z.string().min(1, 'Informe a descrição'),
  price: z.coerce.number().min(0, 'Preço inválido'),
  categoryId: z.string().min(1, 'Selecione a categoria'),
  quantity: z.coerce.number().min(0, 'Quantidade inválida'),
})

type ProductFormData = z.infer<typeof productSchema>

export function ProductsPage() {
  const { isAuthenticated } = useAuth()
  const queryClient = useQueryClient()
  const [search, setSearch] = useState('')
  const [categoryId, setCategoryId] = useState('')
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null)

  const { data: categories, isError: categoriesError } = useQuery({
    queryKey: ['categories'],
    queryFn: listCategories,
    enabled: isAuthenticated,
  })

  const {
    data: productsData,
    isLoading,
    isError: productsError,
  } = useQuery({
    queryKey: ['products', search, categoryId],
    queryFn: () =>
      listProducts({
        search: search || undefined,
        categoryId: categoryId || undefined,
        page: 1,
        pageSize: 20,
      }),
    enabled: isAuthenticated,
  })

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<ProductFormData>({
    resolver: zodResolver(productSchema) as Resolver<ProductFormData>,
    defaultValues: {
      name: '',
      description: '',
      price: 0,
      categoryId: '',
      quantity: 0,
    },
  })

  useEffect(() => {
    if (selectedProduct) {
      reset({
        id: selectedProduct.id,
        name: selectedProduct.name,
        description: selectedProduct.description,
        price: selectedProduct.price,
        categoryId: selectedProduct.categoryId,
        quantity: selectedProduct.quantity,
      })
    } else {
      reset({
        name: '',
        description: '',
        price: 0,
        categoryId: '',
        quantity: 0,
      })
    }
  }, [selectedProduct, reset])

  const createMutation = useMutation({
    mutationFn: createProduct,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] })
      reset()
      setSelectedProduct(null)
    },
  })

  const updateMutation = useMutation({
    mutationFn: updateProduct,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] })
      reset()
      setSelectedProduct(null)
    },
  })

  const deleteMutation = useMutation({
    mutationFn: deleteProduct,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] })
    },
  })

  const stockMutation = useMutation({
    mutationFn: ({ id, quantity }: { id: string; quantity: number }) =>
      updateProductStock(id, quantity),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] })
    },
  })

  const onSubmit: SubmitHandler<ProductFormData> = (values) => {
    if (values.id) {
      updateMutation.mutate(values)
    } else {
      createMutation.mutate(values)
    }
  }

  function handleEdit(product: Product) {
    setSelectedProduct(product)
  }

  function handleClear() {
    setSelectedProduct(null)
    reset({
      name: '',
      description: '',
      price: 0,
      categoryId: '',
      quantity: 0,
    })
  }

  return (
    <div className="grid gap-8 lg:grid-cols-[2fr_1fr]">
      <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
        <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
          <div>
            <h2 className="text-lg font-semibold text-slate-900">Produtos</h2>
            <p className="text-sm text-slate-500">Gerencie o catálogo completo</p>
          </div>
          <div className="flex flex-1 flex-col gap-3 md:flex-row md:justify-end">
            <input
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="Buscar produto"
              className="w-full rounded-full border border-slate-200 bg-slate-50 px-4 py-2 text-sm text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-400 md:max-w-[220px]"
            />
            <select
              value={categoryId}
              onChange={(event) => setCategoryId(event.target.value)}
              className="w-full rounded-full border border-slate-200 bg-white px-4 py-2 text-sm text-slate-600 focus:outline-none focus:ring-2 focus:ring-indigo-400 md:max-w-[200px]"
            >
              <option value="">Todas as categorias</option>
              {categories?.map((category) => (
                <option key={category.id} value={category.id}>
                  {category.name}
                </option>
              ))}
            </select>
          </div>
        </div>

        {productsError && (
          <div className="mb-4 rounded-lg border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-500">
            Não foi possível carregar os produtos. Verifique se você está autenticado.
          </div>
        )}

        <div className="mt-6 overflow-hidden rounded-2xl border border-slate-200">
          <table className="w-full text-left text-sm">
            <thead className="bg-slate-50 text-slate-500">
              <tr>
                <th className="px-4 py-3">Produto</th>
                <th className="px-4 py-3">Categoria</th>
                <th className="px-4 py-3">Preço</th>
                <th className="px-4 py-3">Estoque</th>
                <th className="px-4 py-3 text-right">Ações</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200 text-slate-700">
              {isLoading ? (
                <tr>
                  <td className="px-4 py-6 text-slate-400" colSpan={5}>
                    Carregando produtos...
                  </td>
                </tr>
              ) : productsData?.items.length ? (
                productsData.items.map((product) => (
                  <tr key={product.id}>
                    <td className="px-4 py-4">
                      <div className="font-medium text-slate-900">{product.name}</div>
                      <div className="text-xs text-slate-500">{product.description}</div>
                    </td>
                    <td className="px-4 py-4 text-slate-600">
                      {product.categoryName ?? 'Sem categoria'}
                    </td>
                    <td className="px-4 py-4 text-slate-600">
                      {formatCurrency(product.price)}
                    </td>
                    <td className="px-4 py-4 text-slate-600">
                      <div className="flex items-center gap-2">
                        <input
                          type="number"
                          min={0}
                          defaultValue={product.quantity}
                          onBlur={(event) =>
                            stockMutation.mutate({
                              id: product.id,
                              quantity: Number(event.target.value),
                            })
                          }
                          className="w-20 rounded-lg border border-slate-200 bg-white px-2 py-1 text-xs text-slate-700"
                        />
                        {product.quantity < 10 && (
                          <span className="rounded-full bg-amber-100 px-2 py-1 text-[10px] font-semibold text-amber-700">
                            Baixo
                          </span>
                        )}
                      </div>
                    </td>
                    <td className="px-4 py-4 text-right">
                      <button
                        onClick={() => handleEdit(product)}
                        className="mr-3 text-xs font-medium text-indigo-500 hover:text-indigo-400"
                      >
                        Editar
                      </button>
                      <button
                        onClick={() => deleteMutation.mutate(product.id)}
                        className="text-xs font-medium text-rose-500 hover:text-rose-400"
                      >
                        Excluir
                      </button>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td className="px-4 py-6 text-slate-400" colSpan={5}>
                    Nenhum produto encontrado.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </section>

      <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
        <h2 className="text-lg font-semibold text-slate-900">{selectedProduct ? 'Editar' : 'Novo'} produto</h2>
        <p className="text-sm text-slate-500">Cadastre ou atualize produtos</p>

        <form onSubmit={handleSubmit(onSubmit)} className="mt-6 space-y-4">
          <div>
            <label className="text-xs text-slate-500">Nome</label>
            <input
              {...register('name')}
              className="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700"
            />
            {errors.name && <p className="mt-1 text-xs text-rose-400">{errors.name.message}</p>}
          </div>
          <div>
            <label className="text-xs text-slate-500">Descrição</label>
            <textarea
              {...register('description')}
              rows={3}
              className="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700"
            />
            {errors.description && (
              <p className="mt-1 text-xs text-rose-400">{errors.description.message}</p>
            )}
          </div>
          <div className="grid gap-4 md:grid-cols-2">
            <div>
              <label className="text-xs text-slate-500">Preço</label>
              <input
                type="number"
                step="0.01"
                {...register('price')}
                className="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700"
              />
              {errors.price && <p className="mt-1 text-xs text-rose-400">{errors.price.message}</p>}
            </div>
            <div>
              <label className="text-xs text-slate-500">Quantidade</label>
              <input
                type="number"
                {...register('quantity')}
                className="mt-2 w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-700"
              />
              {errors.quantity && (
                <p className="mt-1 text-xs text-rose-400">{errors.quantity.message}</p>
              )}
            </div>
          </div>
          <div>
            <label className="text-xs text-slate-500">Categoria</label>
            <select
              {...register('categoryId')}
              className="mt-2 w-full rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700"
            >
              <option value="">Selecione</option>
              {categories?.map((category) => (
                <option key={category.id} value={category.id}>
                  {category.name}
                </option>
              ))}
            </select>
            {categoriesError && (
              <p className="mt-1 text-xs text-rose-400">Não foi possível carregar categorias.</p>
            )}
            {errors.categoryId && (
              <p className="mt-1 text-xs text-rose-400">{errors.categoryId.message}</p>
            )}
          </div>

          <div className="flex flex-col gap-3 pt-2">
            <button
              type="submit"
              className="w-full rounded-full bg-indigo-600 px-4 py-2 text-sm font-semibold text-white transition hover:bg-indigo-500"
              disabled={createMutation.isPending || updateMutation.isPending}
            >
              {selectedProduct ? 'Salvar alterações' : 'Cadastrar produto'}
            </button>
            {selectedProduct && (
              <button
                type="button"
                onClick={handleClear}
                className="w-full rounded-full border border-slate-200 px-4 py-2 text-sm font-medium text-slate-600"
              >
                Cancelar edição
              </button>
            )}
          </div>
        </form>
      </section>
    </div>
  )
}
