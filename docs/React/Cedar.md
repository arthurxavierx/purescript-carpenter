## Module React.Cedar

#### `EventHandler`

``` purescript
type EventHandler = forall eff. Eff (props :: ReactProps, refs :: ReactRefs (read :: Read), state :: ReactState ReadWrite | eff) Unit
```

General purpose event handler for React events.

#### `Dispatcher`

``` purescript
type Dispatcher action = action -> EventHandler
```

Type synonym for the action dispatcher function `dispatch`.
Takes an action of type `action` and returns an `EventHandler`.

#### `Yielder`

``` purescript
type Yielder state = (state -> state) -> Aff (state :: ReactState ReadWrite) state
```

Type synonym for the `yield` function which takes a function from the
current state to the new state of the component and asynchronously
updates it.

#### `Update`

``` purescript
type Update state props action eff = Yielder state -> action -> props -> state -> Aff eff state
```

Type synonym for an action handler which takes a `Yielder` supplied by
React's internal rendering function, the dispatched action and the
component's current props and state.

The supplied `yield` function asynchronously updates the component's state.

#### `Render`

``` purescript
type Render state props action = Dispatcher action -> props -> state -> ReactElement
```

Type synonym for a pure render function which takes a `Dispatcher` supplied
by React's internal rendering function and the current props and state for
the component, and returns a `ReactElement`.

The supplied `dispatch` function sends actions to the update function.

#### `spec`

``` purescript
spec :: forall state props action eff. state -> Update state props action eff -> Render state props action -> ReactSpec props state eff
```

Constructs a React component based on an initial state, an update function
and a render function.

#### `spec'`

``` purescript
spec' :: forall state props action eff. state -> action -> Update state props action eff -> Render state props action -> ReactSpec props state eff
```

Constructs a React component spec based on an initial state,
an initial action, an update function and a render function.


