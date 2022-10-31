import React from 'react'
import { render, screen } from '@testing-library/react'
import OptionPriceGraph from './OptionPriceGraph'

test('current2 - renders', () => {
  render(<OptionPriceGraph symbol="some-symbol" />)
  const el = screen.getByText(/some-symbol/i)
  expect(el).toBeInTheDocument()
})
