
import React from 'react'
import styled from 'styled-components'

const W0 = styled.div`
  > ul {
    > li {
      border: 1px solid red;
      display: inline-block;
      padding: .2em;
      margin-right: .2em;

      > a {
      }
    }
  }
`;

const MainMenu = () => {
  return (<W0>
    <ul>
      <li>
        <a href="/manager/gameui/maps">Maps</a>
        <div>
          <form action="/manager/gameui/maps" method="get">
            <input name="utf8" type="hidden" value="✓" />
            <input type="text" name="q" id="q" />
          </form>
        </div>
        <a href="/manager/gameui/maps/new">[+]</a>
      </li>

      <li>
        <a href="/manager/galleries">Galleries</a>
        <div>
          <form action="/manager/galleries" method="get">
            <input name="utf8" type="hidden" value="✓" />
            <input type="text" name="q" id="q" />
          </form>
        </div>
        <a href="/manager/galleries/new">[+]</a>
      </li>

      <li>
        <a href="/manager/reports">Reports</a>
        <div>
          <form action="/manager/reports" method="get">
            <input name="utf8" type="hidden" value="✓" />
            <input type="text" name="q" id="q" />
          </form>
        </div>
        <a href="/manager/reports/new">[+]</a>
      </li>

      <li>
        <a href="/manager/videos">Videos</a>
        <div>
          <form action="/manager/videos" method="get">
            <input name="utf8" type="hidden" value="✓" />
            <input type="text" name="q" id="q" />
          </form>
        </div>
        <a href="/manager/videos/new">[+]</a>
      </li>
    </ul>

    <ul>
      <li><a href="/manager/newsitems/new">+Newsitem</a></li>
      <li><a href="/iron_warbler/stock_watches">Stock Watches</a></li>
      <li><a href="/manager/user_profiles">Profiles</a></li>
    </ul>
  </W0>)
}

export default MainMenu
