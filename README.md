# purescript-carpenter

[![Latest release](https://img.shields.io/npm/v/purescript-carpenter.svg)](https://github.com/ecliptic/purescript-carpenter/releases)
[![Latest release](https://img.shields.io/bower/v/purescript-carpenter.svg)](https://github.com/ecliptic/purescript-carpenter/releases)
[![Build Status](https://travis-ci.org/arthur-xavier/purescript-carpenter.svg?branch=master)](https://travis-ci.org/arthur-xavier/purescript-carpenter)

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
