## Module React.Carpenter.Elm

#### `ElmProps`

``` purescript
type ElmProps state action = { state :: state, release :: action -> EventHandler }
```

#### `ElmClass`

``` purescript
type ElmClass state action = ReactClass (ElmProps state action)
```

#### `spec`

``` purescript
spec :: forall state action eff. Update state (ElmProps state action) action eff -> Render state (ElmProps state action) action -> ReactSpec (ElmProps state action) state eff
```

#### `capture`

``` purescript
capture :: forall state action. ReactClass (ElmProps state action) -> (action -> EventHandler) -> state -> Array ReactElement -> ReactElement
```

#### `capture'`

``` purescript
capture' :: forall state action. ReactClass (ElmProps state action) -> (action -> EventHandler) -> state -> ReactElement
```

#### `elm`

``` purescript
elm :: forall state action. ReactClass (ElmProps state action) -> state -> Array ReactElement -> ReactElement
```

#### `elm'`

``` purescript
elm' :: forall state action. ReactClass (ElmProps state action) -> state -> ReactElement
```

#### `ignore`

``` purescript
ignore :: forall action. action -> EventHandler
```


