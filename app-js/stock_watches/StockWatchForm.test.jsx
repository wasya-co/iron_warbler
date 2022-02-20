
import { render, screen } from '@testing-library/react'
import StockWatchForm from './StockWatchForm'

test('renders', () => {
  render(<WtockWatchForm />)
  const el = screen.getByText(/when/i)
  expect(el).toBeInTheDocument()
})
