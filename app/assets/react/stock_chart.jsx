
import React from "react"
import {
  CartesianGrid,
  Line, LineChart,
  ResponsiveContainer,
  Scatter, ScatterChart,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts"

const Dot = (props) => {
  const { cx, cy, payload } = props
  if (!cx || !cy) return null
  if (!payload || !payload.isOverflow) return null

  return (
    <circle
      cx={cx}
      cy={cy}
      r={4}
      fill={"#880000"}
    />
  )
}

/*
 * Stock Line Chart
**/
export default function StockChart({ data }) {
  logg(data, 'StockChart')
  const { items, min, max } = data


  const normalized = items.map(d => {
    let isOverflow, value
    if (d.value > max ) {
      isOverflow = true
      value = Math.min(d.value, max)
    } else if (d.value < min ) {
      isOverflow = true
      value = Math.max(d.value, min)
    } else {
      isOverflow = false
      value = d.value
    }

    return {
      ...d,
      rawValue: d.value,
      value,
      isOverflow,
    }
  })

  return (
    <div style={{ width: "400px", height: '400px' }}>
      <ResponsiveContainer width="100%" height="100%" >
        <LineChart data={normalized} >
          <CartesianGrid />

          <XAxis dataKey='date'
                //  tickFormatter={v => v.substring(10)}
                 tick={{ angle: -45, textAnchor: 'end' }}
                 height={100}
          />
          <YAxis domain={[min, max]} />

          <Tooltip />
          <Line
            dataKey="value"
            dot={<Dot />}
            name="META"
            stroke="#0088FE"
            type="linear"
          />

        </LineChart>
      </ResponsiveContainer>
    </div>
  )
}