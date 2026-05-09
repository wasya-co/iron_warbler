import React from "react"
import { createRoot } from "react-dom/client"
import Chart from "./chart"

function mount() {
  const el = document.getElementById("Chart")
  if (!el) return

  const data = JSON.parse( el.dataset.props )
  console.log('hellooo11', data)


  createRoot(el).render(<Chart data={data} />)
}

document.addEventListener("DOMContentLoaded", mount)