import React from "react"
import {
  Bar,
  BarChart,
  CartesianGrid,
  DefaultZIndexes,
  ErrorBar,
  Rectangle,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts"


const barDataKey = (entry) => [
  Math.min(entry.close, entry.open),
  Math.max(entry.close, entry.open),
]

const whiskerDataKey = (entry) => {
  const highEnd = Math.max(entry.close, entry.open)
  return [highEnd - entry.low, entry.high - highEnd]
}

const formatTime = (timestamp) => {
  const date = new Date(timestamp)
  return date.toLocaleString(undefined, {
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  })
}

const formatPrice = (value) =>
  value == null ? "—" : Number(value).toFixed(2)

const MIN_CANDLE_HEIGHT = 3 // px
const Candlestick = (props) => {
  // logg(props, 'Candlestick')

  const d = props.payload || props
  const color = d.open <= d.close ? "#16a34a" : "#dc2626"
  return <Rectangle {...props} height={Math.max(props.height, MIN_CANDLE_HEIGHT)} fill={color} stroke="none" />
}

const TT = ({ active, payload }) => {
  if (!active || !payload?.length) return null
  const item = payload[0].payload
  return (
    <div className="TT">
      <ul>
        <li><b>time:</b> {formatTime(item.time)}</li>
        <li><b>open:</b> {formatPrice(item.open)}</li>
        <li><b>high:</b> {formatPrice(item.high)}</li>
        <li><b>low:</b> {formatPrice(item.low)}</li>
        <li><b>close:</b> {formatPrice(item.close)}</li>
      </ul>
    </div>
  )
}

export default function ChartOption({ data }) {
  // logg(data, 'ChartOption')

  const candles = Array.isArray(data) ? data : []

  if (!candles.length) {
    return (
      <div style={{ width: "800px", height: "200px", border: "1px solid #ccc", padding: 16 }}>
        No priceitem OHLC data to chart.
      </div>
    )
  }

  return (
    <div style={{ width: "800px", height: "480px", border: "1px solid #ccc" }}>
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={candles} margin={{ top: 16, right: 24, bottom: 8, left: 8 }}>
          <CartesianGrid vertical={false} strokeDasharray="3 3" />
          <XAxis
            dataKey="time"
            tickFormatter={formatTime}
            minTickGap={40}
          />
          <YAxis
            domain={["dataMin - 0.05", "dataMax + 0.05"]}
            tickFormatter={formatPrice}
            width={56}
          />
          <Tooltip content={<TT />} />
          <Bar dataKey={barDataKey} shape={Candlestick} isAnimationActive={false}>
            <ErrorBar
              dataKey={whiskerDataKey}
              width={0}
              stroke="#111"
              strokeWidth={1}
              zIndex={DefaultZIndexes.bar - 1}
            />
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}
