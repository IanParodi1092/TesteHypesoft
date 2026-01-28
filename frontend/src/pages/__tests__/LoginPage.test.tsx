import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { LoginPage } from '../LoginPage'

vi.mock('../../auth/AuthContext', () => ({
  useAuth: () => ({
    login: vi.fn(),
    isReady: true,
    error: undefined,
    isAuthenticated: false,
  }),
}))

describe('LoginPage', () => {
  it('renders login button', () => {
    render(
      <MemoryRouter>
        <LoginPage />
      </MemoryRouter>
    )

    expect(screen.getByText('Entrar com Keycloak')).toBeInTheDocument()
  })
})
