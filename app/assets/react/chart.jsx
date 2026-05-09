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


export default function Chart({ data }) {
  console.log('+++ Chart')

  const min = 300
  const max = 500
  const interval = 10

  const ticks = []
  for (let v=min; v<max; v+=interval) {
    ticks.push(v)
  }

  const filtered = (which) => {
    return which.filter( w =>  w.strike > min && w.strike < max )
  }

  console.log(filtered(data.puts), 'hmm')

  return (
    <div style={{ width: "800px", height: '800px' }}>
      <ResponsiveContainer width="100%" height="100%" >
        <ScatterChart >
          <CartesianGrid />

          <XAxis type='number' dataKey='iv' ticks={ticks} domain={[min,max]} />
          <YAxis reversed type='number' dataKey="strike" ticks={ticks} domain={[min,max]} />

          <Tooltip />
          <Scatter data={filtered( data.puts )} fill='#333333' />
          <Scatter data={filtered( data.puts_1 )} fill='#666666' />
          <Scatter data={filtered( data.calls )} fill='#ef4444' />
          <Scatter data={filtered( data.calls_1 )} fill='#ff00ff' />
        </ScatterChart>
      </ResponsiveContainer>
    </div>
  )
}