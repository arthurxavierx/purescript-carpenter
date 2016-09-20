## Module Carpenter.Cedar

#### `CedarProps`

``` purescript
type CedarProps state action = { initialState :: state, handler :: CedarHandler state action }
```

Type synonym for internal props of Cedar components.

#### `CedarHandler`

``` purescript
data CedarHandler state action
```

#### `CedarClass`

``` purescript
type CedarClass state action = ReactClass (CedarProps state action)
```

Type synonym for a ReactClass using the Cedar architecture with specific
types for the component's state and actions.

#### `cedarSpec`

``` purescript
cedarSpec :: forall state action eff. Update state (CedarProps state action) action eff -> Render state (CedarProps state action) action -> ReactSpec (CedarProps state action) state eff
```

Creates a specification of a component using the Cedar architecture based
on the supplied update and render functions.

The Cedar architecture is highly based on the Elm architecture but it
allows the existance of multiple sources of truth. That means it allow you
to break the upward bubbling of actions up to the root component. You can
choose to capture or ignore the actions dispatched by child components
using the `capture` and `ignore` functions respectively.

#### `cedarSpec'`

``` purescript
cedarSpec' :: forall state action eff. action -> Update state (CedarProps state action) action eff -> Render state (CedarProps state action) action -> ReactSpec (CedarProps state action) state eff
```

Creates a specification of a Cedar component which emits a default initial
action and has the specified update and render functions.

#### `capture`

``` purescript
capture :: forall state action. ReactClass (CedarProps state action) -> (action -> EventHandler) -> state -> Array ReactElement -> ReactElement
```

Creates an element of the specificed React class with initial state
and children, and captures its dispatched actions.

`capture` and `capture'` are mostly used to dispatch actions to the parent
component based on actions dispatched to the child component, e.g:

```purescript
data MyParentAction
  = ActionA
  | ActionB String
  | ChildAction MyChildAction

-- ...

render :: forall props. Render MyParentState props MyParentAction
capture myChildClass (dispatch <<< ParentAction) 0 []
```

#### `capture'`

``` purescript
capture' :: forall state action. ReactClass (CedarProps state action) -> (action -> EventHandler) -> state -> ReactElement
```

Creates an element of the specificed React class with initial state,
and captures its dispatched actions.

#### `watch`

``` purescript
watch :: forall state action. ReactClass (CedarProps state action) -> (state -> EventHandler) -> state -> Array ReactElement -> ReactElement
```

Creates an element of the specified React class with initial state
and children, and watches for changes to its internal state.

`watch` and `watch'` are mostly used to dispatch actions to the parent
component when the state of the child component changes, e.g:

#### `watch'`

``` purescript
watch' :: forall state action. ReactClass (CedarProps state action) -> (state -> EventHandler) -> state -> ReactElement
```

Creates an element of the specified React class with initial state,
and watches for changes to its internal state.

#### `watchAndCapture`

``` purescript
watchAndCapture :: forall state action. ReactClass (CedarProps state action) -> (action -> state -> EventHandler) -> state -> Array ReactElement -> ReactElement
```

Creates an element of the specified React class with initial state
and children, and watches for changes to its internal state.
The handler function is then called with the dispatched action which
caused the state change and the updated state.

#### `watchAndCapture'`

``` purescript
watchAndCapture' :: forall state action. ReactClass (CedarProps state action) -> (action -> state -> EventHandler) -> state -> ReactElement
```

Creates an element of the specified React class with initial state,
and watches for changes to its internal state.
The handler function is then called with the dispatched action which
caused the state change and the updated state.

#### `ignore`

``` purescript
ignore :: forall state action. ReactClass (CedarProps state action) -> state -> Array ReactElement -> ReactElement
```

Creates an element of the specificed React class with initial state
and children, and ignores its dispatched actions and internal state.

#### `ignore'`

``` purescript
ignore' :: forall state action. ReactClass (CedarProps state action) -> state -> ReactElement
```

Creates an element of the specificed React class with initial state,
and ignores its dispatched actions and internal state.

#### `mockUpdate`

``` purescript
mockUpdate :: forall state action eff. Update state (CedarProps state action) action eff -> action -> state -> Aff eff state
```

Generates an update function for testing with mock `yield` and `dispatch`
functions, which do not depend on React, but return the modified state and
behave as expected.


