
import React, { Fragment as F, useEffect, useState } from 'react'
import { LineChart, Line, CartesianGrid, XAxis, YAxis } from 'recharts'
import PropTypes from 'prop-types'

import { logg, useApi, } from "$shared"

const OptionPriceGraph = (props) => {
  logg(props, 'OptionPriceGraph')
  const {
    symbol: _s,
    fromDate: _f,
    toDate: _t,
  } = props

  const api = useApi()

  const [ ticker, setTicker ] = useState('')
  const [symbol, setSymbol] = useState(_s)
  const [fromDate, setFromDate] = useState(_f)
  const [toDate, setToDate] = useState(_t)
  const [data, setData] = useState([])
  const [refresh, setRefresh] = useState(0)

  let priceMin = 0
  let priceMax = 1


  useEffect(() => {
    api.getOptionPriceItems({symbol, fromDate, toDate }).then((r) => {

      const prices = data.map((d) => d.bid) + data.map((d) => d.ask)
      priceMin = Math.min(prices)
      priceMax = Math.max(prices)

      setData(r)
    }) // @TODO: catch here
  }, [refresh])

  return <F>
    <h1>
      <input value={symbol} onChange={e => setSymbol(e.target.value)} />
      <input value={fromDate} onChange={e => setFromDate(e.target.value)} />
      <input value={toDate} onChange={e => setToDate(e.target.value)} />
      <button onClick={() => setRefresh(refresh+1)}>Refresh</button>
      <button onClick={() => {}}>Get Symbol Info</button>
      <input value={ticker} onChange={e => setTicker(e.target.value)} />
      <button onClick={() => {}}>Get Ticker Info</button>
    </h1>
    <LineChart width={400} height={400} data={data}>
      <Line type="monotone" dataKey="bid" stroke="#8884d8" />
      <Line type="monotone" dataKey="ask" stroke="#0084d8" />
      <CartesianGrid stroke="#ccc" />
      <XAxis dataKey="timestamp" />
      <YAxis type='number' domain={[priceMin, priceMax]} />
    </LineChart>
  </F>
}
OptionPriceGraph.propTypes = {
  symbol: PropTypes.string,
  fromDate: PropTypes.string,
  toDate: PropTypes.string,
}

export default OptionPriceGraph
