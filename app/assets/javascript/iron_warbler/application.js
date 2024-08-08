
//= require ./gameui
//= require ./stock

// console.log('Loaded iron_warbler/application.js')

const appRouter = {
  showStockPath: (symbol) => `/trading/stocks/${symbol}`,
}
