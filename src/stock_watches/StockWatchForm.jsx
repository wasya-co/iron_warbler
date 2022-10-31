
import PropTypes from 'prop-types'
import React, { Fragment as F, useContext, useEffect, useState, } from 'react'
import styled from 'styled-components'

import { jwtManager } from 'ishlibjs'

import { logg, } from '$shared'

const { JwtContext } = jwtManager

const Cell = styled.div`
  display: inline;
`;

const W = styled.div`

  border: 1px solid gray;

  display: flex;
  flex-wrap: wrap;

  .form-group {
    display: inline;
  }

  > div {
    padding: .2em;
  }
`;

//
// @TODO: rename to StockWatch
//
const StockWatchForm = (props) => {
  // logg(props, 'StockWatchForm')
  const { item } = props
  const {
    action: _a,
    direction: _d,
    email: _e,
    price: _p,
    profile_id: _profile_id,
    ticker: _t,
  } = item

  const { api } = useContext(JwtContext)

  const [action, setAction] = useState(_a)
  const [direction, setDirection] = useState(_d)

  const changeDirection = (inn) => {
    logg(inn, 'changeDirection')
  }

  const [email, setEmail] = useState(_e)

  const [ price, setPrice ] = useState(_p)
  const [ profileId, setProfileId ] = useState(_profile_id)

  const [ ticker, setTicker ] = useState(_t)

  const doSubmit = () => {
    api.postStockWatch(item).then(resp => {
      // toast('Success.') // @TODO: wire toast
    }).catch(err => {
      logg(err, 'e-544 cannot create stockWatch')
    })
  }

  return <W>
    <Cell>
      { /* <label>Notify by</label> */ }
      <select value={action} name="stock_watch[action]" onChange={(e) => setAction(e.target.value) } >
        <option value="NONE"  >NONE</option>
        <option value="EMAIL" >EMAIL</option>
        <option value="SMS"   >SMS</option>
      </select>
    </Cell>
    <Cell>
      { /* <label>Email</label>
      <select name="stock_watch[email]">
        <option value="piousbox@gmail.com">piousbox@gmail.com</option>
      </select>
      <input name="stock_watch[email]" value={email} onChange={e => setEmail(e.target.value)} /> */ }
      <input name="stock_watch[profile_id]" value={profileId} onChange={e => setEmail(e.target.value)} />
    </Cell>
    <Cell>
      <label>When</label>
      <input name="stock_watch[ticker]" value={ticker} onChange={e => setTicker(e.target.value)} />
    </Cell>
    <Cell>
      <label>Price</label>
      <select value={direction} name="stock_watch[direction]" onChange={changeDirection} >
        <option value=""      >NONE</option>
        <option value="ABOVE" >ABOVE</option>
        <option value="BELOW" >BELOW</option>
      </select>
    </Cell>
    <Cell>
      <label>$</label>
      <input name="stock_watch[price]" value={price} onChange={e => setPrice(e.target.value)} />
    </Cell>
    <Cell>
      <button onClick={doSubmit} >Go</button>
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
