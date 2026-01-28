import api from './api'
import type { Dashboard } from '../types'

export async function getDashboard() {
  const response = await api.get<Dashboard>('/api/dashboard')
  return response.data
}
