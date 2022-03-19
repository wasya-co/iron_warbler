
import { render, screen } from '@testing-library/react'
import StockWatchForm from './StockWatchForm'

test('renders', () => {
  render(<StockWatchForm />)
  const el = screen.getByText(/when/i)
  expect(el).toBeInTheDocument()
})
