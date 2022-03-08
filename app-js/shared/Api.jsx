import React, { useContext } from 'react'

import config from 'config'
import {
  C, // @TODO: this is replicated in ishjs and iron_warbler - should be in one place only, maybe?
  logg, // eslint-disable-line no-unused-vars
  request,
} from "$shared"

const useApi = () => {
  const jwt_token = localStorage.getItem(C.jwt_token);

  return {
    doUnlock: ({ kind, id }) => {
      return `/api/payments/unlock?kind=${kind}&id=${id}&jwt_token=${jwt_token}`;
    },

    getMyAccount: () => {
      return request.get(`/api/users/me?jwt_token=${jwt_token}`).then(r => r.data)
    },
    getOptionPriceItems: ({ symbol, fromDate, toDate }) => {
      return request.get(`/api/option_price_items/${symbol}?from_date=${fromDate}&` +
        `to_date=${toDate}&jwt_token=${jwt_token}`
      ).then(r => r.data)
    },
    getStockWatches: () => {
      return request.get(`/api/stock_watches?jwt_token=${jwt_token}`)
    },

    // loginPath: '/api/users/login.json',
    longTermTokenPath: '/api/users/long_term_token', // @TODO: move to... a config that's injected into JwtManager

    myVideosPath: "/api/my/videos",

    paymentsPath: "/api/payments2",

    postStockWatch: (props) => {
      throw 'not implemented'
      logg(props, 'api.postStockWatch')
    },

    postLoginWithPassword: ({ email, password }) => {
      return request.post("/api/users/login.json", { email, password, }).then(r => r.data)
    },

    reportsGet: (a) => {
      const currentUser = JSON.parse(localStorage.getItem("current_user")) || {};
      let jwt = "";
      if (currentUser) {
        jwt = `jwt_token=${currentUser.jwt_token}`
      }
      return `${config.apiOrigin}/api/reports/view/${a}?${jwt}`;
    },

    getCities: ()   => request.get(`${config.apiOrigin}/api/cities`).then((r) => r.data),
    getCity: (slug) => request.get(`${config.apiOrigin}/api/cities/view/${slug}`),
    getTag: (tag) => request.get(`${config.apiOrigin}/api/tags/view/${tag.slug}`).then((r) => r.data),

    applicationHome: async () => {
      const out = await request.get(`${config.apiOrigin}/api/sites/view/${config.domain}`, { params: { jwt_token, } })
      return out.data
    }
  }

}

export default useApi
