# The Carpenter guide

A Carpenter application is nothing more than a React application, that is, a tree of React components, given that Carpenter only provides an interface to state management in React applications with PureScript.

## Components

Definitions of Carpenter components describe how to render the component given its current **state** and how to respond and mutate the state according to received **actions** dispatched by the component itself.

Thus, they're defined in terms of:

- An _actions_ type, which represents the actions to which the component can react;
- A _state_ type, which represents the mutable state of the component, which can be changed by dispatching actions to the component;
- A _props_ type, which represents the immutable properties with which the component can be instantiated;
- An _initial state_ or _initial action_;
- A _rendering function_, which takes the component's current state and props, and creates React elements;
- And an _update function_, which receives actions dispatched to the component and modifies its state and/or runs computations (which can be asynchronous).

The _Cedar_ module, explained later in this guide defines components in terms of only the type of _actions_, the type of _state_, a _rendering function_ and an _update function_. As it is inspired by the _Elm_ architecture, _props_ and the _initial state_ aren't needed there.

### Simple components

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
counterComponent :: R.ReactClass _
counterComponent = R.createClass $ C.spec 0 update render
```

After that we're ready to use the above defined component in a React application just by instantiating it with React's `createFactory` or `createElement` functions:

```purescript
R.createFactory counterComponent {}
-- or
R.createElement counterComponent {} []
```

### Effectful actions

In many applications, one may want to perform effects (even asynchronous ones) when initializing a component, in response to some event or user action.

For that matter, Carpenter's _update_ function uses the `Aff` monad, which allows us to perform asynchronous effects in response to dispatched actions.

Carpenter also provides an alternative function for defining component specifications `spec'` which allows us to set an initial action (instead of an initial state) for a component; enabling, thus, a way of performing effects when instantiating a component.

We'll modify the above defined _Counter_ component so that we can load the count from an external API component is initialized, and log to the console when the counter gets incremented or decremented. For that we need only to add a new action `Init` to the `Action` type, change the `update` function and the way we create the `counterComponent` React class to use the `spec'` function.

```purescript
getCountFromAPI :: Aff _ State

update :: forall eff. C.Update State _ Action (console :: CONSOLE | eff)
update yield _ action _ _ =
  case action of
    Init -> do
      count <- getCountFromAPI
      yield (const count)
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
counterComponent :: R.ReactClass _
counterComponent = R.createClass $ C.spec' 0 Init update render
```

## Combining components

By building upon React's well defined foundations for component-based architectures, Carpenter components can be easily combined, just as in normal React applications. For simple (monoidal) combinations of components, such as side-by-side or disconnected parent-child components, we can simply instantiate the components side-by-side or inside the render function of a parent component:

```purescript
counterComponent :: R.ReactClass _
counterComponent = R.createClass $ C.spec 0 update render

counter :: R.ReactElement
counter = R.createFactory counterComponent {}
```

```purescript
parentRender :: C.Render ParentState _ ParentAction
parentRender _ _ _ _ =
  R.div'
    [ R.h1' [ text "Here are 5 counters" ]
    , R.ul' $ map (\_ -> R.li' [ counter ]) (range 1 5)
    ]

parentComponent :: R.ReactClass _
parentComponent = R.createClass $ C.spec {} parentUpdate parentRender
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
    pure state

renderEditText :: C.Render EditTextState EditTextProps EditTextAction
renderEditText dispatch props state _ =
  R.input
    [ P._type "text"
    , P.onChange \e -> dispatch $ Change (unsafeCoerce e).target.value
    , P.onKeyUp \e ->
        if e.charCode == 13
          then dispatch Submit
          else pure unit
    ]

editTextComponent :: R.ReactClass EditTextProps
editTextComponent = R.createClass $ spec '' updateEditText renderEditText

editText :: (EditTextState -> C.EventHandler) -> R.ReactElement
editText onSubmit = R.createFactory editTextComponent { onSubmit: onSubmit }
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

It is easy to see the above exemplified architecture doesn't scale very well in an application. It is way too specific, and, for large applications, many event handlers would be needed and managing all this tightly coupled states, actions and effects can be quite cumbersome. Though it can be good for creating independent components which can be distributed and used in many different applications.

With the above defined architecture it's also not possible to initialize child components from parent components with some custom state in a simple manner without defining an initial action.

To solve these problems, we can use the architectures explained below: the **Elm** architecture, and the **Cedar** architecture.

## The Elm architecture with Carpenter

> The Elm Architecture is a simple pattern for architecting webapps. It is great for modularity, code reuse, and testing. Ultimately, it makes it easy to create complex web apps that stay healthy as you refactor and add features.
>
> _https://guide.elm-lang.org/architecture/_

The Elm architecture organizes the whole application as a single component having a single source of truth. Child components are actually just elements rendered inside other elements parametrized with some part of the application state.

That is, parent components are responsible for rendering child components with some part of its state (which must itself come from another parent component); and the root component for the application is responsible for updating the application state based on actions dispatched by its child components.

This way, using Carpenter, child components must not be defined using Carpenter's specs; they're not React components. They must only define an _update_ and a _rendering_ function. So let's see how the Counter List example goes using the Elm architecture with Carpenter:

```purescript
type Counter = Int

data CounterAction = Increment | Decrement | Remove

update :: CounterAction -> Counter -> Maybe Counter
update action state =
  case action of
    Increment ->
      Just (state + 1)
    Decrement ->
      Just (state - 1)
    Remove ->
      Nothing

render :: Dispatcher CounterAction -> Counter -> ReactElement
render dispatch state =
  div'
    [ h1' [text (show state)]
    , button [onClick \_ -> dispatch Increment] [text "+"]
    , button [onClick \_ -> dispatch Decrement] [text "-"]
    , button [onClick \_ -> dispatch Remove] [text "X"]
    ]
```

A `Dispatcher` is needed, though, in the `render` function, otherwise we couldn't handle events.

The root component (CounterList) must only render the child components, passing its own dispatcher in a way it accepts actions of type `CounterAction` as parameter, and update its state based on these dispatched actions:

```purescript
type CounterList = Array Counter

data CounterListAction = Add | UpdateCounter Int CounterAction

update :: forall props eff. Update CounterList props CounterListAction eff
update yield _ action _ _ =
  case action of
    Add ->
      yield \state -> snoc state 0

    UpdateCounter i caction -> do
      yield $ mapMaybe id <<< mapWithIndex (updateCounter i caction)

  where
    updateCounter id caction i counter
      | id == i   = Counter.update caction counter
      | otherwise = Just counter

render :: forall props. Render CounterList props CounterListAction
render dispatch _ state _ =
  div'
    [ div' $ mapWithIndex (\i c -> Counter.render (dispatch <<< UpdateCounter i) c) state
    , button [onClick \_ -> dispatch Add] [text "++"]
    ]
```

## The Cedar architecture

Apart from the Elm architecture, Carpenter defines another architecture called _Cedar_, which can be seen as an enhanced Elm architecture, in the way that it allows us to exactly replicate the Elm architecture by capturing the actions dispatched by child components and also watch for changes in the state of these child components. With Cedar we also define child components as propr React components, enabling React to do some optimizations.

This way, Cedar allows for multiple sources of truth, instead of only one, as the Elm architecture does. This gives us freedom to break the chain of action propagation at any point and to have self-contained, independent components. This can be done by simply ignoring the actions and changes of state of child components with the `ignore` function.

### List of counters example

A counter component for a list of counters is almost the same as our simple counter component defined above. The difference is that now we can remove a counter too. But a counter can't remove itself, because it's an isolated, independent component. It can also exist without being inside a list of counters, so we must do nothing within the counter component when we receive a `Remove` action.

To write our new component we must now import `Carpenter.Cedar`:

```purescript
import Carpenter.Cedar as C
```

```purescript
type Counter = Int

data CounterAction = Increment | Decrement | Remove

updateCounter :: forall props eff. C.Update Counter props CounterAction eff
updateCounter yield _ action _ state =
  case action of
    Increment ->
      yield (_ + 1)
    Decrement ->
      yield (_ - 1)
    Remove ->
      pure state

renderCounter :: forall props. C.Render Counter props CounterAction
renderCounter dispatch _ state _ =
  div'
    [ span' [text (show state)]
    , button [onClick \_ -> dispatch Increment] [text "+"]
    , button [onClick \_ -> dispatch Decrement] [text "-"]
    , button [onClick \_ -> dispatch Remove] [text "X"]
    ]

counterComponent :: C.CedarClass Counter CounterAction
counterComponent = createClass $ C.cedarSpec updateCounter renderCounter
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
    CounterAction i Remove ->
      yield \state -> fromMaybe state $ deleteAt i state
    CounterAction _ _ ->
      yield id
```

For the _render_ function, the only thing missing is to render all the counters from the array and map its actions to the actions of the counter list. This can be done by using the `capture'` function from `Carpenter.Cedar`:

```purescript
capture' counterComponent (dispatch <<< CounterAction index) counter
```

Thus, for the `renderCounterList` we have:

```purescript
renderCounterList :: forall props. C.Render CounterList props CounterListAction
renderCounterList dispatch _ state _ =
  div'
    [ div' $ mapWithIndex (\i counter -> capture' counterComponent (dispatch <<< CounterAction i) counter) state
    , button [onClick \_ -> dispatch Add] [text "++"]
    ]
```

And last but not least, as stated above, we must not use Cedar for all the components. Our `counterList` component can be defined using Carpenter's simple specs.

```purescript
counterListComponent :: R.ReactClass _
counterListComponent = createClass $ spec [0] updateCounterList renderCounterList
```

### `capture`

The `capture` (and `capture'`) functions can be used to capture actions dispatched by child components before they're processed by the child component itself, that is, before the state of the child component gets updated. This being so allows for some performance enhancements, in the way that we save a rendering cycle because of an unnecessary state update, as the most common use for this function is to update the parent's state based on some child action, which would, in its turn, cause a re-render of the component tree.

```purescript
data ParentAction = SomeChildAction ChildAction

capture' childComponent (dispatch <<< SomeChildAction) childState
```

Using the `capture` function we can do the Elm architecture with Cedar, but apart from Elm, every component is a React component, and can, thus, be distributed and reused anywhere.

### `watch`

The `watch` (and `watch'`) functions can be used to watch for state changes on the child component.

```purescript
data ParentAction = ChildStateChanged ChildState

watch' childComponent (dispatch <<< ChildStateChanged) childState
```

### `watchAndCapture`

The `watchAndCapture` (and `watchAndCapture'`) functions can be used to capture actions dispatched by child components and watch for the state of this child component after the processing of the dispatched action.

```purescript
data ParentAction = ChildStateChanged ChildAction ChildState

watchAndCapture' childComponent (\action state -> dispatch $ ChildStateChanged action state) childState
```

### `ignore`

The `ignore` (and `ignore'`) functions can be used to instantiate a child component without capturing its actions or watching for changes in its internal state.

```purescript
ignore' childComponent childState
```

## Testing components

Testing components with Carpenter (and Cedar) is really straightforward and practical. In almost all of the cases, unit testing on interface components are done on the state management of the component, that is, on the _update_ function. For that, Carpenter and Cedar provide, each one, a function `mockUpdate`, which takes an update function and returns a new update function which mocks React's state management for simple unit testing.

Below is an example of unit testing a Cedar component (from [purescript-carpenter-todomvc](https://github.com/arthur-xavier/purescript-carpenter-todomvc)):

```purescript
testTask = runTest do

  suite "Task" do

    test "should set edits to description on focus" do
      let t = Just (Task.init "Lorem" 1)
          expected = updateTask (_ { edits = Just "Lorem" }) t
      t' <- update Task.Focus t
      Assert.equal expected t'

    test "should change description after commiting edits" do
      let t = Just (Task.init "Lorem" 1)
          expected = Just (Task.init "Ipsum" 1)
      t' <- update (Task.Edit "Ipsum") t >>= update Task.Commit
      Assert.equal expected t'

  where
    update = mockUpdate Task.update
```
