
import { Fragment as F } from 'react'
import styled from 'styled-components'

import { logg } from '$shared'

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
  logg(props, 'StockWatchForm')
  const { price, ticker } = props

  return <W>
    <F>
      <label>Action</label>
      <select>
        <option>none</option>
        <option>email</option>
      </select>
    </F>
    <Cell>
      <label>Profile</label>
      <select>
        <option>piousbox@gmail.com</option>
      </select>
    </Cell>
    <Cell>
      <label>When</label>
      <input name="ticker" value={ticker} />
    </Cell>
    <Cell>
      <label>Price</label>
      <select>
        <option>above</option>
        <option>below</option>
      </select>
    </Cell>
    <Cell>
      <label>$</label>
      <input name="price" value={price} />
    </Cell>
    <Cell>
      <button>Go</button>
    </Cell>
  </W>
}

export default StockWatchForm
