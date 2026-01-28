import { render, screen } from '@testing-library/react'
import { StatCard } from '../StatCard'

describe('StatCard', () => {
  it('renders label and value', () => {
    render(<StatCard label="Total" value="123" helper="info" />)

    expect(screen.getByText('Total')).toBeInTheDocument()
    expect(screen.getByText('123')).toBeInTheDocument()
    expect(screen.getByText('info')).toBeInTheDocument()
  })
})
