import api from './api'
import type { PagedResult, Product } from '../types'

export type ProductInput = {
  id?: string
  name: string
  description: string
  price: number
  categoryId: string
  quantity: number
}

export async function listProducts(params: {
  search?: string
  categoryId?: string
  page?: number
  pageSize?: number
}) {
  const response = await api.get<PagedResult<Product>>('/api/products', { params })
  return response.data
}

export async function getProduct(id: string) {
  const response = await api.get<Product>(`/api/products/${id}`)
  return response.data
}

export async function createProduct(payload: ProductInput) {
  const response = await api.post<Product>('/api/products', payload)
  return response.data
}

export async function updateProduct(payload: ProductInput) {
  if (!payload.id) {
    throw new Error('Id obrigatório')
  }
  const response = await api.put<Product>(`/api/products/${payload.id}`, payload)
  return response.data
}

export async function updateProductStock(id: string, quantity: number) {
  const response = await api.patch<Product>(`/api/products/${id}/stock`, {
    id,
    quantity,
  })
  return response.data
}

export async function deleteProduct(id: string) {
  await api.delete(`/api/products/${id}`)
}

export async function listLowStock(threshold = 10) {
  const response = await api.get<Product[]>('/api/products/low-stock', {
    params: { threshold },
  })
  return response.data
}
