# purescript-carpenter

[![purescript-carpenter on Pursuit](https://pursuit.purescript.org/packages/purescript-carpenter/badge)](https://pursuit.purescript.org/packages/purescript-carpenter)
[![Latest release](https://img.shields.io/bower/v/purescript-carpenter.svg)](https://github.com/arthur-xavier/purescript-carpenter/releases)
[![Latest release](https://img.shields.io/npm/v/purescript-carpenter.svg)](https://www.npmjs.com/package/purescript-carpenter)
[![Build Status](https://travis-ci.org/arthur-xavier/purescript-carpenter.svg?branch=master)](https://travis-ci.org/arthur-xavier/purescript-carpenter)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](http://commitizen.github.io/cz-cli/)

Carpenter is a declarative library for type-safe state management in React applications with PureScript. Carpenter provides simple patterns and architectures for building React applications inspired by [Elm](http://elm-lang.org/), [Thermite](https://github.com/paf31/purescript-thermite) and [Halogen](https://github.com/slamdata/purescript-halogen).

- [Module Documentation](https://pursuit.purescript.org/packages/purescript-carpenter)
- [The Carpenter guide](GUIDE.md)
  - 1\. [Components](GUIDE.md#components)
    - 1.1\. [Simple components](GUIDE.md#simple-components)
    - 1.2\. [Effectful actions](GUIDE.md#effectful-actions)
  - 2\. [Combining components](GUIDE.md#combining-components)
    - 2.1\. [Using `EventHandler` for simple event callbacks](GUIDE.md#using-eventhandler-for-simple-event-callbacks)
  - 3\. [The Elm architecture with Carpenter](GUIDE.md#the-elm-architecture-with-carpenter)
  - 4\. [The Cedar architecture](GUIDE.md#the-cedar-architecture)
    - 4.1\. [List of counters example](GUIDE.md#list-of-counters-example)
    - 4.2\. [`capture`](GUIDE.md#capture)
    - 4.3\. [`watch`](GUIDE.md#watch)
    - 4.4\. [`watchAndCapture`](GUIDE.md#watchandcapture)
    - 4.5\. [`ignore`](GUIDE.md#ignore)
  - 5\. [Testing components](GUIDE.md#testing-components)

## Getting started

- Read [the Carpenter guide](GUIDE.md)
- Take a look at some of the examples:
  - [Counter example](examples/Counter/Counter.purs)
  - [Counter list example capturing actions](examples/CounterList/)
  - [Counter list example (Elm architecture)](examples/CounterListElm/)
  - [Writer Monad example](examples/Monad/Writer.purs)
  - [PureScript + Carpenter • TodoMVC](https://github.com/arthur-xavier/purescript-carpenter-todomvc)

## Installing

You can install Carpenter with bower:

```bash
bower install --save purescript-carpenter
```
