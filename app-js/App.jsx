
import React, { useEffect, useState } from 'react'
import styled from 'styled-components'

import config from 'config'
import { jwtManager } from "ishjs"
import { logg, useApi, } from "$shared"
import MainMenu from "./application/MainMenu"
import {
  StockWatch, StockWatchForm, StockWatchItem,
} from './stock_watches'
import OptionPriceGraph from './option_price_items/OptionPriceGraph'
import './App.css'

const { JwtContextProvider, SimpleJwtRow, } = jwtManager

const Header = styled.div``;

const WOuter = styled.div`
  display: flex;
  justify-content: center;
  align-items: stretch;
`;

const WInner = styled.div`
  border: 1px solid gray;
  max-width: 100%;
`;

function App() {
  const api = useApi()

  const [ stockWatches, setStockWatches ] = useState([])

  useEffect(() => {
    api.getStockWatches().then((r) => r.data).then((r) => {
      logg(r, 'rrr')
      setStockWatches(r)
    }) // @TODO: catch here
  }, [])

  return <WOuter className="WOuter"><WInner className="WInner" >
    <JwtContextProvider api={api} >

      <Header>
        <MainMenu />
        <SimpleJwtRow />
      </Header>

      <h1>Welcome home</h1>

      { stockWatches.map((sw, idx) => <StockWatchForm key={idx} item={sw} />) }
      New: <StockWatchForm item={StockWatchItem} />

      <hr />
      <OptionPriceGraph symbol="GME_031822P75" fromDate="2022-02-15" toDate="2022-02-17" />

    </JwtContextProvider>
  </WInner></WOuter>
}

export default App
