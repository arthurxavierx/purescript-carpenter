module Carpenter
  ( spec
  , spec'
  , Render
  , Update
  , Yielder
  , Dispatcher
  , EventHandler
  , ActionHandler
  , CarpenterEffects
  , mockUpdate
  ) where

import Prelude
import React as React
import Control.Monad.Aff (launchAff, makeAff, Aff)
import Control.Monad.Aff.Unsafe (unsafeInterleaveAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Unsafe (unsafeInterleaveEff)

type CarpenterEffects eff = (props :: React.ReactProps, state :: React.ReactState React.ReadWrite | eff)

-- | General purpose event handler for React events.
type EventHandler = ∀ eff. Eff (CarpenterEffects eff) Unit

-- | Handler for dispatches of actions.
-- | Useful when handling actions dispatched by child components, e.g.:
-- |
-- | ```purescript
-- | type MyProps = { onSubmit :: ActionHandler MyAction }
-- | -- ...
-- | createFactory myComponentClass {onSubmit: dispatch AnotherAction}
-- | ```
type ActionHandler action = action -> EventHandler

-- | Type synonym for the action dispatcher function `dispatch`.
-- | Takes an action of type `action` and returns an `EventHandler`.
type Dispatcher action = action -> EventHandler

-- | Type synonym for the `yield` function which takes a function from the
-- | current state to the new state of the component and asynchronously
-- | updates it.
type Yielder state eff = (state -> state) -> Aff (CarpenterEffects eff) state

-- | Type synonym for an action handler which takes a `Yielder` supplied by
-- | React's internal rendering function, a `Dispatcher` used to dispatch
-- | new actions to the same component, the dispatched action and the
-- | component's current props and state.
-- |
-- | The supplied `yield` function asynchronously updates the component's state.
type Update state props action eff
   = Yielder state eff
  -> Dispatcher action
  -> action
  -> props
  -> state
  -> Aff (CarpenterEffects eff) state

-- | Type synonym for a pure render function which takes a `Dispatcher` supplied
-- | by React's internal rendering function and the current props and state for
-- | the component, and returns a `ReactElement`.
-- |
-- | The supplied `dispatch` function sends actions to the update function.
type Render state props action
   = Dispatcher action
  -> props
  -> state
  -> Array React.ReactElement
  -> React.ReactElement

-- | Constructs a React component based on an initial state, an update function
-- | and a render function.
spec :: ∀ state props action eff. state -> Update state props action eff -> Render state props action -> React.ReactSpec props state eff
spec state update render = React.spec state (getReactRender update render)

-- | Constructs a React component spec based on an initial state,
-- | an initial action, an update function and a render function.
spec' :: ∀ state props action eff. state -> action -> Update state props action eff -> Render state props action -> React.ReactSpec props state eff
spec' state action update render = (React.spec state (getReactRender update render)) { componentWillMount = componentWillMount }
  where
    componentWillMount :: React.ComponentWillMount props state eff
    componentWillMount this = void $ do
      props <- React.getProps this
      state <- React.readState this
      let yield = mkYielder this
      let dispatch = mkDispatcher this update yield
      unsafeInterleaveEff (launchAff (update yield dispatch action props state))

-- | Generates an update function for testing with mock `yield` and `dispatch`
-- | functions, which do not depend on React, but return the modified state and
-- | behave as expected.
mockUpdate :: ∀ state props action eff. Update state props action eff -> action -> props -> state -> Aff eff state
mockUpdate update action props state = unsafeInterleaveAff (update mockYield mockDispatch action props state)
  where
    mockYield f = pure (f state)
    mockDispatch :: Dispatcher action
    mockDispatch action = void $ unsafeInterleaveEff (launchAff (update mockYield mockDispatch action props state))

--
--
mkYielder :: ∀ props state eff. React.ReactThis props state -> Yielder state eff
mkYielder this = \f ->
  makeAff \_ resolve -> void do
    old <- React.readState this
    let new = f old
    React.writeStateWithCallback this new (resolve new)

mkDispatcher
  :: ∀ state props action eff
   . React.ReactThis props state
  -> Update state props action eff
  -> Yielder state eff
  -> Dispatcher action
mkDispatcher this update yield = dispatch
  where
    dispatch :: Dispatcher action
    dispatch action = void $ unsafeInterleaveEff $ launchAff do
      props <- liftEff $ React.getProps this
      state <- liftEff $ React.readState this
      update yield dispatch action props state

getReactRender :: ∀ state props action eff. Update state props action eff -> Render state props action -> React.Render props state eff
getReactRender update render this = do
  props <- React.getProps this
  state <- React.readState this
  children <- React.getChildren this
  let yield = mkYielder this
  let dispatch = mkDispatcher this update yield
  pure $ render dispatch props state children
