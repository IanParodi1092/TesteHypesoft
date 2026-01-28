export type Product = {
  id: string
  name: string
  description: string
  price: number
  categoryId: string
  categoryName?: string | null
  quantity: number
  createdAt: string
  updatedAt: string
}

export type Category = {
  id: string
  name: string
}

export type CategoryCount = {
  categoryId: string
  categoryName: string
  count: number
}

export type Dashboard = {
  totalProducts: number
  totalStockValue: number
  lowStockProducts: Product[]
  productsByCategory: CategoryCount[]
}

export type PagedResult<T> = {
  items: T[]
  totalCount: number
  page: number
  pageSize: number
}
