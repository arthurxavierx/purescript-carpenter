module React.Carpenter.Elm
  ( spec
  , capture
  , capture'
  , elm
  , elm'
  , ignore
  , ElmProps
  , ElmClass
  ) where

import Prelude
import React as React
import Control.Monad.Aff (launchAff)
import Control.Monad.Eff.Unsafe (unsafeInterleaveEff)
import React.Carpenter (Dispatcher, mkYielder, Render, Update, EventHandler)

type ElmProps state action =
  { state :: state
  , release :: action -> EventHandler
  }

type ElmClass state action = React.ReactClass (ElmProps state action)

spec :: ∀ state action eff. Update state (ElmProps state action) action eff -> Render state (ElmProps state action) action -> React.ReactSpec (ElmProps state action) state eff
spec update render = React.spec' getInitialState (getReactRender update render)
  where
    getInitialState :: React.GetInitialState (ElmProps state action) state eff
    getInitialState this = React.getProps this >>= pure <<< _.state

    getReactRender :: Update state (ElmProps state action) action eff -> Render state (ElmProps state action) action -> React.Render (ElmProps state action) state eff
    getReactRender update render this = do
      props <- React.getProps this
      state <- React.readState this
      let yield = mkYielder this
      let dispatch :: Dispatcher action
          dispatch action = void $ do
            props.release action
            unsafeInterleaveEff (launchAff (update yield action props state))
      pure $ render dispatch props state

capture :: ∀ state action. React.ReactClass (ElmProps state action) -> (action -> EventHandler) -> state -> Array React.ReactElement -> React.ReactElement
capture reactClass release state children = React.createElement reactClass {state: state, release: release} children

capture' :: ∀ state action. React.ReactClass (ElmProps state action) -> (action -> EventHandler) -> state -> React.ReactElement
capture' reactClass release state = React.createFactory reactClass {state: state, release: release}

elm :: ∀ state action. React.ReactClass (ElmProps state action) -> state -> Array React.ReactElement -> React.ReactElement
elm reactClass state children = React.createElement reactClass {state: state, release: ignore} children

elm' :: ∀ state action. React.ReactClass (ElmProps state action) -> state -> React.ReactElement
elm' reactClass state = React.createFactory reactClass {state: state, release: ignore}

ignore :: ∀ action. action -> EventHandler
ignore _ = pure unit
