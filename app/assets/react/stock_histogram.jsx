
import React from "react"
import {
  Bar, BarChart,
  CartesianGrid,
  Line, LineChart,
  ResponsiveContainer,
  Scatter, ScatterChart,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts"


/*
 * StockHistogram
**/
export default function StockHistogram({ data }) {
  logg(data, 'StockHist')
  const { items, min, max } = data

  return (
    <div style={{ width: "400px", height: '200px' }}>
      <ResponsiveContainer width="100%" height="100%" >
        <BarChart data={items} >
          <CartesianGrid
          />

          <XAxis dataKey='bucket'
                //  tickFormatter={v => v.substring(10)}
                 tick={{ angle: -45, textAnchor: 'end' }}
                 height={100}
          />
          <YAxis domain={[min, max]} />

          <Tooltip
          />
          <Bar
            dataKey="count"
            barSize={10}
          />

        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}

