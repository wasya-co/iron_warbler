
import React, { useEffect, useState } from 'react'
import styled from 'styled-components'

import config from 'config'
import { jwtManager } from "ishjs"
import { logg, useApi, } from "$shared"
import MainMenu from "./application/MainMenu"
import { StockWatch, StockWatchForm, StockWatchItem, } from './stock_watches'
import './App.css'

const { JwtContextProvider, SimpleJwtRow, } = jwtManager

const Header = styled.div``;

const WOuter = styled.div`
  display: flex;
  justify-content: center;
  align-items: stretch;
  height: 100%;
`;

const WInner = styled.div`
  border: 1px solid gray;
  width: 900px;
`;

function App() {
  const api = useApi()

  const [ stockWatches, setStockWatches ] = useState([])

  useEffect(() => {
    api.getStockWatches().then((r) => {
      setStockWatches(r.data)
    }) // @TODO: catch here
  }, [])

  return <WOuter><WInner>
    <JwtContextProvider api={api} >

      <Header>
        <MainMenu />
        <SimpleJwtRow />
      </Header>

      <h1>Welcome home</h1>

      { stockWatches.map((sw, idx) => <StockWatchForm key={idx} {...sw} />) }

      <StockWatchForm item={StockWatchItem} />

    </JwtContextProvider>
  </WInner></WOuter>
}

export default App
