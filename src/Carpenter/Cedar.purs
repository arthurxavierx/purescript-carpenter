module Carpenter.Cedar
  ( spec
  , capture
  , capture'
  , ignore
  , ignore'
  , CedarProps
  , CedarClass
  ) where

import Prelude
import React as React
import Carpenter (ActionHandler, Dispatcher, mkYielder, Render, Update, EventHandler)
import Control.Monad.Aff (launchAff)
import Control.Monad.Eff.Unsafe (unsafeInterleaveEff)

type CedarProps state action =
  { initialState :: state
  , handler :: ActionHandler action
  }

type CedarClass state action = React.ReactClass (CedarProps state action)

spec :: ∀ state action eff. Update state (CedarProps state action) action eff -> Render state (CedarProps state action) action -> React.ReactSpec (CedarProps state action) state eff
spec update render = React.spec' getInitialState (getReactRender update render)
  where
    getInitialState :: React.GetInitialState (CedarProps state action) state eff
    getInitialState this = React.getProps this >>= pure <<< _.initialState

    getReactRender :: Update state (CedarProps state action) action eff -> Render state (CedarProps state action) action -> React.Render (CedarProps state action) state eff
    getReactRender update render this = do
      props <- React.getProps this
      state <- React.readState this
      let yield = mkYielder this
      let dispatch :: Dispatcher action
          dispatch action = void $ do
            props.handler action
            unsafeInterleaveEff (launchAff (update yield action props state))
      pure $ render dispatch props state

capture :: ∀ state action. React.ReactClass (CedarProps state action) -> (action -> EventHandler) -> state -> Array React.ReactElement -> React.ReactElement
capture reactClass handler state children = React.createElement reactClass {initialState: state, handler: handler} children

capture' :: ∀ state action. React.ReactClass (CedarProps state action) -> (action -> EventHandler) -> state -> React.ReactElement
capture' reactClass handler state = React.createFactory reactClass {initialState: state, handler: handler}

ignore :: ∀ state action. React.ReactClass (CedarProps state action) -> state -> Array React.ReactElement -> React.ReactElement
ignore reactClass state children = React.createElement reactClass {initialState: state, handler: \_ -> pure unit} children

ignore' :: ∀ state action. React.ReactClass (CedarProps state action) -> state -> React.ReactElement
ignore' reactClass state = React.createFactory reactClass {initialState: state, handler: \_ -> pure unit}
