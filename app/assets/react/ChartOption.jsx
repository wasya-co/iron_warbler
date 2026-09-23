import React from "react"
import {
  ScatterChart,
  Scatter,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  LineChart,
} from "recharts"

/* tooltip */
const TT = ({ active, payload, label }) => {
  if (!payload.length) { return }
  const item = payload[0].payload
  return <div className='TT'>
    <ul>
      <li><b>strike:</b> { item.strike } </li>
      <li><b>price:</b> { item.price }</li>
      <li><b>implied:</b> { item.implied }</li>
    </ul>
  </div>
}

/*
 *
**/
export default function ChartOption({ data }) {
  console.log('+++ ChartOption:', data)

  // const min = data.min
  // const max = data.max

  // const interval = 10
  // const ticks = []
  // for (let v=min; v<max; v+=interval) {
  //   ticks.push(v)
  // }

  // const filtered = (which) => {
  //   return which.filter( w =>  w.strike > min && w.strike < max )
  // }
  // console.log(filtered(data.puts), 'filtered')

  return (
    <div style={{ width: "800px", height: '800px', border: '1px solid blue' }}>
      <ResponsiveContainer width="100%" height="100%" >
        <ScatterChart >
          <CartesianGrid />

          <XAxis type='number' dataKey='implied' ticks={ticks} domain={[min,max]} />
          <YAxis reversed type='number' dataKey="strike" ticks={ticks} domain={[min,max]} />

          <Tooltip content={<TT />} />
          <Scatter data={filtered( data.puts )} fill='#666666' />
          <Scatter data={filtered( data.puts_1 )} fill='#999999' />
          <Scatter data={filtered( data.calls )} fill='#ef4444' />
          <Scatter data={filtered( data.calls_1 )} fill='#ff0099' />

          <Scatter data={ data.last } fill='#000000' />
        </ScatterChart>
      </ResponsiveContainer>
    </div>
  )
}