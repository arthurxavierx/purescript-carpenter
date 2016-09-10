module React.Cedar
  ( spec
  , spec'
  , Render
  , Update
  , Yielder
  , Dispatcher
  , EventHandler
  ) where

import Prelude
import React as React
import Control.Monad.Aff (launchAff, makeAff, Aff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Unsafe (unsafeInterleaveEff)

-- | General purpose event handler for React events.
type EventHandler = ∀ eff. Eff
  ( props :: React.ReactProps
  , refs :: React.ReactRefs (read :: React.Read)
  , state :: React.ReactState React.ReadWrite
  | eff) Unit

-- | Type synonym for the action dispatcher function `dispatch`.
-- | Takes an action of type `action` and returns an `EventHandler`.
type Dispatcher action = action -> EventHandler

-- | Type synonym for the `yield` function which takes a function from the
-- | current state to the new state of the component and asynchronously
-- | updates it.
type Yielder state eff = (state -> state) -> Aff (state :: React.ReactState React.ReadWrite | eff) state

-- | Type synonym for an action handler which takes a `Yielder` supplied by
-- | React's internal rendering function, the dispatched action and the
-- | component's current props and state.
-- |
-- | The supplied `yield` function asynchronously updates the component's state.
type Update state props action eff
   = Yielder state eff
  -> action
  -> props
  -> state
  -> Aff eff state

-- | Type synonym for a pure render function which takes a `Dispatcher` supplied
-- | by React's internal rendering function and the current props and state for
-- | the component, and returns a `ReactElement`.
-- |
-- | The supplied `dispatch` function sends actions to the update function.
type Render state props action
   = Dispatcher action
  -> props
  -> state
  -> React.ReactElement

-- | Constructs a React component based on an initial state, an update function
-- | and a render function.
spec :: ∀ state props action eff. state -> Update state props action eff -> Render state props action -> React.ReactSpec props state eff
spec state update render = React.spec state (getReactRender update render)

-- | Constructs a React component spec based on an initial state,
-- | an initial action, an update function and a render function.
spec' :: ∀ state props action eff. state -> action -> Update state props action eff -> Render state props action -> React.ReactSpec props state eff
spec' state action update render = (React.spec state (getReactRender update render)) { componentDidMount = componentDidMount }
  where
    componentDidMount :: React.ComponentDidMount props state eff
    componentDidMount this = void $ do
      props <- React.getProps this
      state <- React.readState this
      let yield = mkYielder this
      unsafeInterleaveEff (launchAff (update yield action props state))

--
--
mkYielder :: ∀ props state eff. React.ReactThis props state -> Yielder state eff
mkYielder this = yield
  where
    yield :: Yielder state eff
    yield f = makeAff \_ resolve -> unsafeInterleaveEff $ void do
      old <- React.readState this
      let new = f old
      React.writeStateWithCallback this new (unsafeInterleaveEff $ resolve new)

getReactRender :: ∀ state props action eff . Update state props action eff -> Render state props action -> React.Render props state eff
getReactRender update render this = do
  props <- React.getProps this
  state <- React.readState this
  let yield = mkYielder this
  let dispatch :: Dispatcher action
      dispatch action = void $ unsafeInterleaveEff (launchAff (update yield action props state))
  pure $ render dispatch props state
