
//= require ./gameui
//= require ./stock

// console.log('Loaded iron_warbler/application.js')

const appRouter = {
  showStockPath: (symbol) => `/trading/stocks/${symbol}`,
}


import React from "react"
import { createRoot } from "react-dom/client"
import Chart from "./components/Chart"

document.addEventListener("DOMContentLoaded", () => {
  const el = document.getElementById("Chart")

  if (el) {
    createRoot(el).render(<Chart />)
  }
})


