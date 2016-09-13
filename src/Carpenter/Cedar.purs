module Carpenter.Cedar
  ( cedarSpec
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

-- | Type synonym for internal props of Cedar components.
type CedarProps state action =
  { initialState :: state
  , handler :: ActionHandler action
  }

-- | Type synonym for a ReactClass using the Cedar architecture with specific
-- | types for the component's state and actions.
type CedarClass state action = React.ReactClass (CedarProps state action)

-- | Creates a `ReactSpec` using the Cedar architecture for the component based
-- | on the supplied update and render functions.
-- |
-- | The Cedar architecture is highly based on the Elm architecture but it
-- | allows the existance of multiple sources of truth. That means it allow you
-- | to break the upward bubbling of actions up to the root component. You can
-- | choose to capture or ignore the actions dispatched by child components
-- | using the `capture` and `ignore` functions respectively.
cedarSpec
  :: ∀ state action eff
   . Update state (CedarProps state action) action eff
  -> Render state (CedarProps state action) action
  -> React.ReactSpec (CedarProps state action) state eff
cedarSpec update render = React.spec' getInitialState (getReactRender update render)
  where
    getInitialState :: React.GetInitialState (CedarProps state action) state eff
    getInitialState this = React.getProps this >>= pure <<< _.initialState

    getReactRender
      :: Update state (CedarProps state action) action eff
      -> Render state (CedarProps state action) action
      -> React.Render (CedarProps state action) state eff
    getReactRender update render this = do
      props <- React.getProps this
      state <- React.readState this
      children <- React.getChildren this
      let yield = mkYielder this
      let dispatch :: Dispatcher action
          dispatch action = void $ do
            props.handler action
            unsafeInterleaveEff (launchAff (update yield action props state))
      pure $ render dispatch props state children

-- | Creates an element of the specificed React class with initial state
-- | and children and captures its dispatched actions.
-- |
-- | `capture` and `capture'` and mostly used to dispatch actions to the parent
-- | component based on actions dispatched to the child component, e.g:
-- |
-- | ```purescript
-- | data MyParentAction
-- |   = ActionA
-- |   | ActionB String
-- |   | ChildAction MyChildAction
-- | -- ...
-- | render :: forall props. Render MyParentState props MyParentAction
-- | capture myChildClass (dispatch <<< ParentAction) 0 []
-- | ```
capture :: ∀ state action. React.ReactClass (CedarProps state action) -> (action -> EventHandler) -> state -> Array React.ReactElement -> React.ReactElement
capture reactClass handler state children = React.createElement reactClass {initialState: state, handler: handler} children

capture' :: ∀ state action. React.ReactClass (CedarProps state action) -> (action -> EventHandler) -> state -> React.ReactElement
capture' reactClass handler state = React.createFactory reactClass {initialState: state, handler: handler}

-- | Creates an element of the specificed React class with initial state
-- | and children and ignores its dispatched actions.
ignore :: ∀ state action. React.ReactClass (CedarProps state action) -> state -> Array React.ReactElement -> React.ReactElement
ignore reactClass state children = React.createElement reactClass {initialState: state, handler: \_ -> pure unit} children

ignore' :: ∀ state action. React.ReactClass (CedarProps state action) -> state -> React.ReactElement
ignore' reactClass state = React.createFactory reactClass {initialState: state, handler: \_ -> pure unit}
