
$(document).ready(() => {

  $('select[name="stock_selector"]').on('change', (ev) => {
    // logg(ev, 'ev')
    window.location = appRouter.showStockPath(ev.target.value)
  })

})
