# purescript-carpenter

[![Latest release](https://img.shields.io/npm/v/purescript-carpenter.svg)](https://github.com/ecliptic/purescript-carpenter/releases)
[![Latest release](https://img.shields.io/bower/v/purescript-carpenter.svg)](https://github.com/ecliptic/purescript-carpenter/releases)
[![Build Status](https://travis-ci.org/arthur-xavier/purescript-carpenter.svg?branch=master)](https://travis-ci.org/arthur-xavier/purescript-carpenter)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](http://commitizen.github.io/cz-cli/)

Carpenter provides an interface to React in PureScript, highly insired by inspired by [Elm](http://elm-lang.org/) and [Thermite](https://github.com/paf31/purescript-thermite).
Carpenter also provides simple patterns and architectures for dealing with more complex applications.

- [Module Documentation](docs/)

## Related Modules
- [React](https://github.com/purescript-contrib/purescript-react)

## Install

You can install Carpenter with bower:

```bash
bower install --save purescript-carpenter
```

## Getting started

Carpenter is a component-based library for state management in React applications with PureScript. It provides functions and types for managing state in a type-safe way.

Carpenter components are React components built in a different way. Carpenter components are defined in terms of:

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
update yield Increment _ _ = yield (_ + 1)
update yield Decrement _ _ = yield (_ - 1)
```

The update function takes a function for first argument that asynchronously reads the current state and updates it based on a function passed as argument. The other arguments of the update function are respectively the dispatched _action_ and the components current _props_ and _state_.

The last piece for our Counter component is the _rendering_ function, which must take the components current _state_ and return a `ReactElement`. It also must have the rendered elements dispatch actions to the update function in response to events:

```purescript
render :: C.Render State _ Action
render dispatch _ state =
  R.div'
    [ R.span' [ R.text (show state) ]
    , R.button [ P.onClick \_ -> dispatch Increment ] [ R.text "+" ]
    , R.button [ P.onClick \_ -> dispatch Decrement ] [ R.text "-" ]
    ]
```

And last but not least, maybe the most important part of Carpenter is to build a React class based on the Carpenter specification of the component. Built using Carpenter's `spec` function, this specification takes an initial state for the component and its update and render functions:

```purescript
counterClass :: ReactClass _
counterClass = R.createClass $ C.spec 0 update render
```

After that we're ready to use the above defined component in a React application just by instantiating it with React's `createFactory` or `createElement` functions:

```purescript
R.createFactory counterClass {}
-- or
R.createElement counterClass {} []
```
