
import { render, screen } from '@testing-library/react'
import StockWatch from './StockWatch'

test('renders', () => {
  render(<StockWatch />)
  const el = screen.getByText(/when/i)
  expect(el).toBeInTheDocument()
})
