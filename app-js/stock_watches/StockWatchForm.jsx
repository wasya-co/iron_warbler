
import PropTypes from 'prop-types'
import React, { Fragment as F } from 'react'
import styled from 'styled-components'

import { useApi, logg, } from '$shared'

const Cell = styled.div`
  display: inline;
`;

const W = styled.div`
  display: flex;
  border: 1px solid gray;

  .form-group {
    display: inline;
  }

  > div {
    padding: .2em;
  }
`;


const StockWatchForm = (props) => {
  // logg(props, 'StockWatchForm')
  const { item } = props

  const api = useApi()

  const doSubmit = () => {
    api.postStockWatch(item).then(resp => {
      // toast('Success.') // @TODO: wire toast
    }).catch(err => {
      logg(err, 'e-544 cannot create stockWatch')
    })
  }

  return <W>
    <Cell>
      <label>Notify by</label>
      <select name="stock_watch[action]">
        <option value="NONE">NONE</option>
        <option value="EMAIL">EMAIL</option>
        <option value="SMS">SMS</option>
      </select>
    </Cell>
    <Cell>
      <label>Email</label>
      <select name="stock_watch[email]">
        <option value="piousbox@gmail.com">piousbox@gmail.com</option>
      </select>
    </Cell>
    <Cell>
      <label>When</label>
      <input name="stock_watch[ticker]" value={item.ticker} />
    </Cell>
    <Cell>
      <label>Price</label>
      <select name="stock_watch[direction]">
        <option value="ABOVE">ABOVE</option>
        <option value="BELOW">BELOW</option>
      </select>
    </Cell>
    <Cell>
      <label>$</label>
      <input name="stock_watch[price]" value={item.price} />
    </Cell>
    <Cell>
      <button onCLick={doSubmit} >Go</button>
    </Cell>
  </W>
}
StockWatchForm.props = {
  item: PropTypes.shape({
    price: PropTypes.number.required,
    ticker: PropTypes.string.required,
  })
}

export default StockWatchForm
