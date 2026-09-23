import React from "react"
import { createRoot } from "react-dom/client"
import Chart from "./chart"
import ChartOption from './ChartOption'
import ChartPrice from "./chart_price"
import StockChart from "./stock_chart"
import StockHistogram from "./stock_histogram"


function mount() {
  let el

  el = document.getElementById("ChartOption")
  if (el) {
    const data = JSON.parse( el.dataset.props )
    createRoot(el).render(<ChartOption data={data} />)
  }

  // 2026-09-23 obsolete?
  el = document.getElementById("Chart")
  if (el) {
    const data = JSON.parse( el.dataset.props )
    createRoot(el).render(<Chart data={data} />)
  }

  // 2026-09-23 obsolete?
  el = document.getElementById("ChartPrice")
  if (el) {
    const data = JSON.parse( el.dataset.props )
    createRoot(el).render(<ChartPrice data={data} />)
  }

  el = document.getElementById("Stock_1mo")
  if (el) {
    const data = JSON.parse( el.dataset.props )
    createRoot(el).render(<StockChart data={data} />)
  }
  el = document.getElementById("StockHist_1mo")
  if (el) {
    const data = JSON.parse( el.dataset.props )
    createRoot(el).render(<StockHistogram data={data} />)
  }

  el = document.getElementById("Stock_3mo")
  if (el) {
    const data = JSON.parse( el.dataset.props )
    createRoot(el).render(<StockChart data={data} />)
  }
  el = document.getElementById("StockHist_3mo")
  if (el) {
    const data = JSON.parse( el.dataset.props )
    createRoot(el).render(<StockHistogram data={data} />)
  }

  el = document.getElementById("Stock_6mo")
  if (el) {
    const data = JSON.parse( el.dataset.props )
    createRoot(el).render(<StockChart data={data} />)
  }
  el = document.getElementById("StockHist_6mo")
  if (el) {
    const data = JSON.parse( el.dataset.props )
    createRoot(el).render(<StockHistogram data={data} />)
  }

  el = document.getElementById("Stock_1yr")
  if (el) {
    const data = JSON.parse( el.dataset.props )
    createRoot(el).render(<StockChart data={data} />)
  }
  el = document.getElementById("StockHist_1yr")
  if (el) {
    const data = JSON.parse( el.dataset.props )
    createRoot(el).render(<StockHistogram data={data} />)
  }
}
document.addEventListener("DOMContentLoaded", mount)
