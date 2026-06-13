import React from "react"
import { createRoot } from "react-dom/client"
import Chart from "./chart"
import Stock_1mo from "./stock_1mo"

function mount() {
  const el = document.getElementById("Chart")
  if (!el) return

  const data = JSON.parse( el.dataset.props )
  // console.log('Chart data', data)

  createRoot(el).render(<Chart data={data} />)
}
document.addEventListener("DOMContentLoaded", mount)


function mount_stock_1mo() {
  const el = document.getElementById("stock_1mo")
  if (!el) return

  const data = JSON.parse( el.dataset.props )
  // console.log('stock_1mo', data)

  createRoot(el).render(<Stock_1mo data={data} />)
}
document.addEventListener("DOMContentLoaded", mount_stock_1mo)



