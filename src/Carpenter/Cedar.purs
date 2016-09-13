module Carpenter.Cedar
  ( cedarSpec
  , capture
  , capture'
  , watch
  , watch'
  , watchAndCapture
  , watchAndCapture'
  , ignore
  , ignore'
  , CedarProps
  , CedarClass
  ) where

import Prelude
import React as React
import Carpenter (ActionHandler, Dispatcher, mkYielder, Render, Update, EventHandler)
import Control.Monad.Aff (launchAff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Unsafe (unsafeInterleaveEff)

-- | Type synonym for internal props of Cedar components.
type CedarProps state action =
  { initialState :: state
  , handleAction :: ActionHandler action
  , handleState :: state -> EventHandler
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
            props.handleAction action
            unsafeInterleaveEff $ launchAff do
              new <- update yield action props state
              liftEff $ props.handleState new
      pure $ render dispatch props state children

-- | Creates an element of the specificed React class with initial state
-- | and children, and captures its dispatched actions.
-- |
-- | `capture` and `capture'` are mostly used to dispatch actions to the parent
-- | component based on actions dispatched to the child component, e.g:
-- |
-- | ```purescript
-- | data MyParentAction
-- |   = ActionA
-- |   | ActionB String
-- |   | ChildAction MyChildAction
-- |
-- | -- ...
-- |
-- | render :: forall props. Render MyParentState props MyParentAction
-- | capture myChildClass (dispatch <<< ParentAction) 0 []
-- | ```
capture :: ∀ state action. React.ReactClass (CedarProps state action) -> (action -> EventHandler) -> state -> Array React.ReactElement -> React.ReactElement
capture reactClass handleAction state children = React.createElement reactClass {initialState: state, handleAction: handleAction, handleState: ignoreHandler} children

-- | Creates an element of the specificed React class with initial state,
-- | and captures its dispatched actions.
capture' :: ∀ state action. React.ReactClass (CedarProps state action) -> (action -> EventHandler) -> state -> React.ReactElement
capture' reactClass handleAction state = React.createElement reactClass {initialState: state, handleAction: handleAction, handleState: ignoreHandler} []

-- | Creates an element of the specified React class with initial state
-- | and children, and watches for changes in its internal state.
-- |
-- | `watch` and `watch'` are mostly used to dispatch actions to the parent
-- | component when the state of the child component changes, e.g:
watch :: ∀ state action. React.ReactClass (CedarProps state action) -> (state -> EventHandler) -> state -> Array React.ReactElement -> React.ReactElement
watch reactClass handleState state children = React.createElement reactClass {initialState: state, handleAction: ignoreHandler, handleState: handleState} children

-- | Creates an element of the specified React class with initial state,
-- | and watches for changes in its internal state.
watch' :: ∀ state action. React.ReactClass (CedarProps state action) -> (state -> EventHandler) -> state -> React.ReactElement
watch' reactClass handleState state = React.createElement reactClass {initialState: state, handleAction: ignoreHandler, handleState: handleState} []

-- | Creates an element of the specified React class with initial state
-- | and children, captures its dispatched actions and watches for changes
-- | in its internal state.
watchAndCapture :: ∀ state action. React.ReactClass (CedarProps state action) -> (state -> EventHandler) -> (action -> EventHandler) -> state -> Array React.ReactElement -> React.ReactElement
watchAndCapture reactClass handleState handleAction state children = React.createElement reactClass {initialState: state, handleAction: handleAction, handleState: handleState} children

-- | Creates an element of the specified React class with initial state,
-- | captures its dispatched actions and watches for changes in its
-- | internal state.
watchAndCapture' :: ∀ state action. React.ReactClass (CedarProps state action) -> (state -> EventHandler) -> (action -> EventHandler) -> state -> React.ReactElement
watchAndCapture' reactClass handleState handleAction state = React.createElement reactClass {initialState: state, handleAction: handleAction, handleState: handleState} []

-- | Creates an element of the specificed React class with initial state
-- | and children, and ignores its dispatched actions and internal state.
ignore :: ∀ state action. React.ReactClass (CedarProps state action) -> state -> Array React.ReactElement -> React.ReactElement
ignore reactClass state children = React.createElement reactClass {initialState: state, handleAction: ignoreHandler, handleState: ignoreHandler} children

-- | Creates an element of the specificed React class with initial state,
-- | and ignores its dispatched actions and internal state.
ignore' :: ∀ state action. React.ReactClass (CedarProps state action) -> state -> React.ReactElement
ignore' reactClass state = React.createElement reactClass {initialState: state, handleAction: ignoreHandler, handleState: ignoreHandler} []

--
--
ignoreHandler :: ∀ a. a -> EventHandler
ignoreHandler _ = pure unit

