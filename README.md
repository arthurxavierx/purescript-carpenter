# purescript-carpenter

[![purescript-carpenter on Pursuit](https://pursuit.purescript.org/packages/purescript-carpenter/badge)](https://pursuit.purescript.org/packages/purescript-carpenter)
[![Latest release](https://img.shields.io/bower/v/purescript-carpenter.svg)](https://github.com/arthur-xavier/purescript-carpenter/releases)
[![Latest release](https://img.shields.io/npm/v/purescript-carpenter.svg)](https://www.npmjs.com/package/purescript-carpenter)
[![Build Status](https://travis-ci.org/arthur-xavier/purescript-carpenter.svg?branch=master)](https://travis-ci.org/arthur-xavier/purescript-carpenter)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](http://commitizen.github.io/cz-cli/)

Carpenter provides an interface to React in PureScript, highly insired by inspired by [Elm](http://elm-lang.org/) and [Thermite](https://github.com/paf31/purescript-thermite).
Carpenter also provides simple patterns and architectures for dealing with more complex applications.

- [Module Documentation](https://pursuit.purescript.org/packages/purescript-carpenter)
- [Counter example](examples/Counter/Counter.purs)
- [Counter list example capturing actions](examples/CounterList/)
- [Counter list example capturing state](examples/CounterList/Maybe/)

## Installing

You can install Carpenter with bower:

```bash
bower install --save purescript-carpenter
```

## Getting started

Carpenter is a library for state management in React applications with PureScript in a type-safe way, which can be easily integrated in any existing application.

Carpenter components are React components built in a different way. They are defined in terms of:

- An _actions_ type, which represents the actions to which the component can react;
- A _state_ type, which represents the mutable state of the component, which can be changed by dispatching actions to the component;
- A _props_ type, which represents the immutable properties with which the component can be instantiated;
- An _initial state_ or _initial action_;
- A _rendering function_, which takes the component's current state and props, and creates React elements;
- And an _update function_, which receives actions dispatched to the component and modifies its state and/or runs computations (which can be asynchronous).

### Counter example

The most basic component we can build to demonstrate how to create simple applications with Carpenter is a _Counter_ component, which displays and increments/decrements the value of an integer counter.

Carpenter only takes care of the state management part of applications. React is needed for rendering, thus we must import it along with Carpenter:

```purescript
import Carpenter as C
import React as R
import React.DOM as R
import React.DOM.Props as P
```

The state of the Counter component can be represented as being just an integer number:

```purescript
type State = Int
```

And the actions to which our Counter can react and change its state are simply _incrementing_ and _decrementing_ the counter value:

```purescript
data Action = Increment | Decrement
```

We have then enough building blocks to construct our _update_ function, which must take incoming actions and yield new state values. Carpenter uses the `Update state props action eff` type to represent an update function:

```purescript
update :: forall eff. C.Update State _ Action eff
update yield _ Increment _ _ = yield (_ + 1)
update yield _ Decrement _ _ = yield (_ - 1)
```

The update function takes a function for first argument that asynchronously reads the current state and updates it based on a function passed as argument. The other arguments of the update function are respectively the dispatched _action_ and the components current _props_ and _state_.

The last piece for our Counter component is the _rendering_ function, which must take the components current _state_ and return a `ReactElement`. It also must have the rendered elements dispatch actions to the update function in response to events:

```purescript
render :: C.Render State _ Action
render dispatch _ state _ =
  R.div'
    [ R.span' [ R.text (show state) ]
    , R.button [ P.onClick \_ -> dispatch Increment ] [ R.text "+" ]
    , R.button [ P.onClick \_ -> dispatch Decrement ] [ R.text "-" ]
    ]
```

And last but not least, maybe the most important part of Carpenter is to build a React class based on the Carpenter specification of the component. Built using Carpenter's `spec` function, this specification takes an initial state for the component and its update and render functions:

```purescript
counterClass :: R.ReactClass _
counterClass = R.createClass $ C.spec 0 update render
```

After that we're ready to use the above defined component in a React application just by instantiating it with React's `createFactory` or `createElement` functions:

```purescript
R.createFactory counterClass {}
-- or
R.createElement counterClass {} []
```

## Effectful actions

In many applications, one may want to perform effects (even asynchronous ones) when initializing a component, in response to some event or user action.

For that matter, Carpenter's _update_ function uses the `Aff` monad, which allows us to perform asynchronous effects in response to dispatched actions.

Carpenter also provides an alternative function for defining component specifications `spec'` which allows us to set an initial action (instead of an initial state) for a component; enabling, thus, a way of performing effects when instantiating a component.

### Counter example with logging to the console

We'll modify the above defined _Counter_ component so that we can log to the console when the component is initialized, and when the counter gets incremented or decremented. For that we need only to add a new action `Init` to the `Action` type, change the `update` function and the way we create the `counterClass` React class to use the `spec'` function:

```purescript
update :: forall eff. C.Update State _ Action (console :: CONSOLE | eff)
update yield _ action _ _ =
  case action of
    Init -> do
      liftEff $ log "Initializing"
      yield (const 0)
    Increment -> do
      liftEff $ log "Incrementing"
      yield (_ + 1)
    Decrementing -> do
      liftEff $ log "Decrementing"
      yield (_ -  1)
```

`liftEff` is needed because the Update function operates inside the `Aff` monad.

```purescript
data Action = Init | Increment | Decrement
```

```purescript
counterClass :: R.ReactClass _
counterClass = R.createClass $ C.spec' Init update render
```

## Combining components

By building upon React's well defined foundations for component-based architectures, Carpenter components can be easily combined, just as in normal React applications. For simple (monoidal) combinations of components, such as side-by-side or disconnected parent-child components, we can simply instantiate the components side-by-side or inside the render function of a parent component:

```purescript
counterClass :: R.ReactClass _
counterClass = R.createClass $ C.spec 0 update render

counter :: R.ReactElement
counter = R.createFactory counterClass {}
```

```purescript
parentRender :: C.Render ParentState _ ParentAction
parentRender _ _ _ _ =
  R.div'
    [ R.h1' [ text "Here are 5 counters" ]
    , R.ul' $ map (\_ -> R.li' [ counter ]) (range 1 5)
    ]

parentClass :: R.ReactClass _
parentClass = R.createClass $ C.spec {} parentUpdate parentRender
```

The above example creates a class of a component which contains a heading text which says _"Here are 5 counters"_ followed by a list of 5 counters.

### Using `EventHandler` for simple event callbacks

When building complex applications, most of the time, simple combinations of components are not enough. We want the components to communicate and interact with each other.

Suppose we have en editable text field component called `editText` with state and action types `type EditTextState = String` and `data EditTextAction = Change String | Submit` respectively. We want a parent component to update an _email_ value when the user submits its changes in the text field. For that we can use event callbacks and have them inside our text field _props_:

```purescript
type EditTextState = String

data EditTextAction = Change String | Submit

type EditTextProps =
  { onSubmit :: EditTextState -> C.EventHandler
  }

updateEditText :: forall eff. C.Update EditTextState EditTextProps EditTextAction eff
updateEditText yield _ action props state =
  Change value ->
    yield (const value)
  Submit ->
    props.onSubmit state
    yield id

renderEditText :: C.Render EditTextState EditTextProps EditTextAction
renderEditText dispatch props state _ =
  R.input
    [ P._type "text"
    , P.onKeyUp \e ->
        if e.charCode == 13
          then dispatch Submit
          else dispatch (Change $ state <> e.key)
    ]

editTextClass :: R.ReactClass EditTextProps
editTextClass = R.createClass $ spec '' updateEditText renderEditText

editText :: (EditTextState -> C.EventHandler) -> R.ReactElement
editText onSubmit = R.createFactory editTextClass { onSubmit: onSubmit }
```

And on our parent component we can have:

```purescript
type ParentState =
  { email :: String
  , password :: String
  , ...
  }

data Action = ChangeEmail String | ChangePassword String | ...

renderParent :: C.Render ParentState _ ParentAction
renderParent dispatch _ _ _ =
  R.div'
    [ R.h3' [ R.text "Email" ]
    , editText (dispatch <<< ChangeEmail)
    ]
```

Now, whenever the user presses the _enter_ key on our text field component, the `onSubmit` event handler gets called and a `ChangeEmail` action is dispatched to the parent component.

### The Elm architecture with `Carpenter.Cedar`

It is easy to see the above exemplified architecture doesn't scale very well. It is way too specific, and, for large applications, many event handlers would be needed and managing all this tightly coupled states, actions and effects can be quite cumbersome.

With the above defined architecture it's also not possible to initialize components with some state in a simple manner without defining an initial action.

For solving these problems we can do some low level machinery and generalize the event handlers for taking the actions of child components instead of their state. This way we can emulate [the Elm architecture](https://guide.elm-lang.org/architecture/).

This emulation of the Elm architecture with Carpenter is called `Cedar`, because it is not exactly like the Elm architecture, since it allows for multiple sources of truth instead of only one, as Elm does. This gives us freedom to break the chain of action propagation at any point, by simply ignoring the actions of child components with the `ignore` function.

#### List of counters example

A counter component for a list of counters is almost the same as our simple counter component defined above. The difference is that now we can remove a counter too. But a counter can't remove itself, because it's an isolated, independent component. It can also exist without being inside a list of counters, so we must do nothing within the counter component when we receive a `Remove` action.

To write our new component we must now import `Carpenter.Cedar`:

```purescript
import Carpenter.Cedar as C
```

```purescript
type Counter = Int

data CounterAction = Increment | Decrement | Remove

updateCounter :: forall props eff. C.Update Counter props CounterAction eff
updateCounter yield _ action _ _ =
  case action of
    Increment ->
      yield (_ + 1)
    Decrement ->
      yield (_ - 1)
    Remove ->
      yield id

renderCounter :: forall props. C.Render Counter props CounterAction
renderCounter dispatch _ state _ =
  div'
    [ span' [text (show state)]
    , button [onClick \_ -> dispatch Increment] [text "+"]
    , button [onClick \_ -> dispatch Decrement] [text "-"]
    , button [onClick \_ -> dispatch Remove] [text "X"]
    ]

counterClass :: C.CedarClass Counter CounterAction
counterClass = createClass $ C.cedarSpec updateCounter renderCounter

counter :: ActionHandler CounterAction -> Counter -> ReactElement
counter = capture' counterClass
```

Our counter component is now defined to have its actions captured by its parent components. It's also defined in a way that we can set the initial value of the counter in a very straightforward fashion.

Now, the parent component, the list of counters can be defined in the same way we defined our first components. That is, we must not use Cedar for every component in the application.

Let's first define the _state_ and _action_ types of our component:

```purescript
type CounterList = Array Counter

data CounterListAction = Add | CounterAction Int CounterAction
```

The state of our list of counters is simply a List or `Array` of `Counter` values, which are integer numbers in fact. The actions our component can take are to add a new counter or an action from a specific counter indexed by its position in the array of counters.

The _update_ function for the list of counters must only append a new counter to the array on an `Add` action, and remove a counter from the array when of a `Remove` action from a child counter:

```purescript
updateCounterList :: forall props eff. C.Update CounterList props CounterListAction eff
updateCounterList yield _ action _ _ =
  case action of
    Add ->
      yield \state -> snoc state 0
    CounterAction i caction ->
      case caction of
        Remove ->
          yield \state -> fromMaybe state $ deleteAt i state
        _ ->
          yield id
```

For the _render_ function, the only thing missing is to render all the counters from the array and map its actions to the actions of the counter list. This can be done by using the `capture` function from `Carpenter.Cedar`, as in the definition of the `counter` function:

```purescript
capture counterClass (dispatch <<< CounterAction index) count
```

Thus, for the `renderCounterList` we have:

```purescript
renderCounterList :: forall props. C.Render CounterList props CounterListAction
renderCounterList dispatch _ state _ =
  div'
    [ div' $ mapWithIndex (\i c -> counter (dispatch <<< CounterAction i) c) state
    , button [onClick \_ -> dispatch Add] [text "++"]
    ]
```

And last but not least, as stated above, we must not use Cedar for all the components. Our `counterList` component can be defined using Carpenter's simple specs.

```purescript
counterListClass :: R.ReactClass _
counterListClass = createClass $ spec [0] updateCounterList renderCounterList
```
