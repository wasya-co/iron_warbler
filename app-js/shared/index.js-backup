/*
 *  $shared / index
 */
// alphabetized
import { arrowBack } from 'ionicons/icons'
import { IonIcon } from '@ionic/react'
import { CircularProgress as _CircularProgress } from '@material-ui/core'
import _Box from '@material-ui/core/Box'
import { ChevronLeft as _ChevronLeft, ChevronRight as _ChevronRight, Menu as _MenuIcon, } from '@material-ui/icons'
import React, { useState } from 'react'
import {
  Link, Switch, BrowserRouter as Router, Redirect, Route as _Route, useHistory, withRouter
} from 'react-router-dom'
import styled from 'styled-components'

import config from 'config'
import C from "./C"

/* A */
export { default as useApi } from "./Api"
export { default as AppMock } from "./AppMock"
export { default as AppRouter } from "./AppRouter"

/* B */

/**
 * Back Button
 */
const BackIcon = styled(IonIcon)`
  margin-right: 5px;
  cursor: pointer;
`;
export const BackBtn = () => {
  const history = useHistory()
  return <BackIcon onClick={history.goBack} icon={arrowBack}></BackIcon>
}

/**
 * Just your regular shadowed box. Pointer cursor. TDD
 */
export const Btn = styled.div`
  border: 1px solid gray;
  border-radius: 5px;

  padding: .3em 1em;
  cursor: pointer;
`;


/* C */

export { C }
export const ChevronLeft = styled(_ChevronLeft)`
  color: ${(p) => p.theme.colors.text}
`;
export const ChevronRight = styled(_ChevronRight)`
  color: ${(p) => p.theme.colors.text}
`;

/**
 * A Card
 */
export const Card = styled(_Box)`
  margin-bottom: 1em;
  padding: 1em;
  background: white;
  cursor: ${p => p.cursor ? p.cursor : 'auto'};

  display: flex;
  flex-direction: column;
`;

export { default as Collapsible } from "./Collapsible"
export const CollapsibleContext = React.createContext({})
/**
 * @TODO: test-driven
 */
export const CollapsibleContextProvider = ({ children, ...props }) => {
  // logg(props, 'CollapsibleContextProvider')

  let defaultCollapsibles = {
    [C.collapsible.descr]: true,
  }
  let tmp
  if (tmp = localStorage.getItem(C.collapsibles)) {
    try {
      defaultCollapsibles = JSON.parse(tmp)
    } catch (err) {
      logg(err, 'Could not parse collapsibles from localStorage')
    }
  }
  const [ collapsibles, _setCollapsibles ] = useState(defaultCollapsibles)
  const setCollapsibles = (m) => {
    localStorage.setItem(C.collapsibles, JSON.stringify(m))
    _setCollapsibles(m)
  }

  return <CollapsibleContext.Provider value={{
    collapsibles, setCollapsibles,
  }} >{ children }</CollapsibleContext.Provider>
}

/* D */
/* I */

/**
 * Like the rails inflector, has methods:
 * tableize()
 */
export const inflector = {
  tableize: (m) => {
    switch(m) {
      case 'Gallery':
        return 'galleries'
      default:
      return `${m.toLowerCase()}s`
    }
  },
}

/* L */


// From: https://codepen.io/charlyarg/pen/GByKja
const _Circle = styled.div`
  position: fixed;
  z-index: 999;
  overflow: show;
  margin: auto;
  top: 0;
  left: 0;
  bottom: 0;
  right: 0;
  width: 50px;
  height: 50px;
`;
export const Loading = (p) => <_Circle><_CircularProgress /></_Circle>

/**
 * Usage: logg(someObject, 'label')
 *
 * This development-grade logger can be used instead of console.log() with some advantages:
 * * It encourages consistent labeling of logs. By labeling each log line, you can have dozens of log lines
 * written per action, and still know which log line comes from where.
 * The recommended label is the component name, or function name.
 * * If the label is present, the logged object is placed in the window, allowing you to inspect it in the console. The
 * label becomes the name of the object (stripped to [0-9a-zA-Z\-_] chars). If you're logging a function, you can execute it.
 * If you log more than one thing, they can interact, allowing you to validate control flow.
 * * the logger can be turned off by making this function simply return.
 */
const logg = (a, b="", c=null) => {
  c = "string" === typeof c ? c : b.replace(/\W/g, "");
  if (c.length > 0) {
    window[c] = a;
  }

  console.log(`+++ ${b}:`, a); // eslint-disable-line no-console
};
// optimized for Android (e.g. it inspects and doesn't use window)
const logg2 = (a, b="", c=null) => {
  console.log(`+++ ${b}:`, a.inspect); // eslint-disable-line no-console
};
export { logg, logg2 };

/* M */
export const MenuIcon = styled(_MenuIcon)`
  color: ${(p) => p.theme.colors.text}
`;

/* P */

/**
 * pretty print date
 */
export const pp_date = (d) => (d || "" ).substring(0, 10)

/* R */

export { default as request } from "./request"

/* S */
export { default as S } from "./S"

/* T */

export const TwofoldContext = React.createContext({})
export const TwofoldContextProvider = ({ children, ...props }) => {
  // logg(props, 'TwofoldContextProvider')
  const {
    currentUser, setCurrentUser,
    layout, setLayout,
    loginModalOpen, setLoginModalOpen,
    theme, toggleTheme,
  } = props

  /* B */
  // @TODO: does localStorage work like this on mobile?
  // @TODO: try and catch
  const [ bottomDrawerOpen, _setBottomDrawerOpen ] = useState(JSON.parse(localStorage.getItem(C.bottomDrawerOpen)))
  const setBottomDrawerOpen = (m) => {
    localStorage.setItem(C.bottomDrawerOpen, JSON.stringify(m))
    _setBottomDrawerOpen(m)
  }

  /* F */
  const [ folded, setFolded ] = useState()

  /* I */
  const [ itemToUnlock, _setItemToUnlock ] = useState({})
  const setItemToUnlock = (item) => {
    if (itemToUnlock.id !== item.id && !loginModalOpen) {
      _setItemToUnlock(item)
    }
  }

  /* M */
  const [ mapPanelWidth, setMapPanelWidth ] = useState(null)
  const [ mapPanelHeight, setMapPanelHeight ] = useState(null)

  /* R */
  const [ ratedConfirmation, _setRatedConfirmation ] = useState(JSON.parse(localStorage.getItem(C.ratedConfirmation)))
  const setRatedConfirmation = (which) => {
    logg(which, 'setting')

    localStorage.setItem(C.ratedConfirmation, JSON.stringify(which))
    _setRatedConfirmation(which)
  }

  /* S */
  const [ showItem, setShowItem ] = useState(false)
  const [ showUrl, setShowUrl ] = useState(false)

  /* T */
  let tmp, defaultTwofoldPercent = 0.5
  if (tmp = localStorage.getItem(C.twofoldPercent)) {
    try {
      defaultTwofoldPercent = JSON.parse(tmp)
    } catch (err) {
      logg(err, 'cannot get twofoldPercent from localStorage')
    }
  }
  const [ twofoldPercent, setTwofoldPercent ] = useState(0.5)

  /* Z */
  const [ zoom, setZoom ] = useState(1)

  return <TwofoldContext.Provider value={{
    bottomDrawerOpen, setBottomDrawerOpen,

    currentUser, setCurrentUser, // @TODO: move this to an AppWrapper context

    folded, setFolded,

    itemToUnlock, setItemToUnlock,

    layout, setLayout,
    loginModalOpen, setLoginModalOpen,

    mapPanelHeight, setMapPanelHeight,
    mapPanelWidth, setMapPanelWidth,

    ratedConfirmation, setRatedConfirmation,

    showItem, setShowItem,
    showUrl, setShowUrl,

    twofoldPercent, setTwofoldPercent,

    zoom, setZoom,

    theme, toggleTheme,
  }} >{ children }</TwofoldContext.Provider>
}

/* U */
export { default as useWindowSize } from './useWindowSize'

/* W */

/**
 * Wrapper Bordered. This expects a list? _vp_ 2021-11-02
 * Used in collapsibles and MarkersList
 */
export const WBordered = styled.div`
  border: ${p => p.theme.thinBorder};
  border-radius: ${p => p.theme.thinBorderRadius};
  background: ${p => p.theme.colors.cardBackground};
  padding: .5em;

  margin-bottom: 1em;
`;

/**
 * Wrapper Bordered Item. Is padded, margined.
 */
export const WBorderedItem = styled.div`
  border: ${p => p.theme.thinBorder};
  border-radius: ${p => p.theme.thinBorderRadius};
  background: ${p => p.theme.colors.cardBackground};
  color: ${p => p.theme.colors.text};

  margin: 0 .5em .5em 0;
  padding: .5em;

  text-align: center;

  width: 18%;
  max-width: 140px;
  min-width: 120px;
`;


export const WidgetContainer = ({ children, ...props }) => {
  return <WBordered {...props} >{ children }</WBordered>
}

export const Wrapper = styled.div`
  height: 100vh;
`;

/* Z */

export const ZoomContext = React.createContext({})



