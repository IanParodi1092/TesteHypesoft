import api from './api'
import type { Category } from '../types'

export async function listCategories() {
  const response = await api.get<Category[]>('/api/categories')
  return response.data
}

export async function createCategory(name: string) {
  const response = await api.post<Category>('/api/categories', { name })
  return response.data
}

export async function deleteCategory(id: string) {
  await api.delete(`/api/categories/${id}`)
}
