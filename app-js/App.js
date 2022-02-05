
import { useEffect, useState } from 'react'
import styled from 'styled-components'

import { logg } from "$shared"
import { StockWatch, StockWatchForm, } from './stock_watches'

console.log(logg, 'ze logg')

const W = styled.div``

function App() {

  const [ stockWatches, setStockWatches ] = useState([])

  useEffect(() => {
    fetch("/api/stock_watches").then((r) => {
      logg(r, 'response')
    })
  }, [])

  return <W>
    <ul>
      <li><a href="/manager">Back to manager</a></li>
      <li><a hrerf="/iron_warbler/stock_watches">Stock Watches</a></li>
    </ul>

    <h1>Welcome home</h1>

    { stockWatches.map((sw, idx) => <StockWatch key={idx} {...sw} />) }

    <StockWatchForm />

  </W>
}

export default App
