## Module Carpenter.Cedar

#### `CedarProps`

``` purescript
type CedarProps state action = { state :: state, release :: action -> EventHandler }
```

#### `CedarClass`

``` purescript
type CedarClass state action = ReactClass (CedarProps state action)
```

#### `spec`

``` purescript
spec :: forall state action eff. Update state (CedarProps state action) action eff -> Render state (CedarProps state action) action -> ReactSpec (CedarProps state action) state eff
```

#### `capture`

``` purescript
capture :: forall state action. ReactClass (CedarProps state action) -> (action -> EventHandler) -> state -> Array ReactElement -> ReactElement
```

#### `capture'`

``` purescript
capture' :: forall state action. ReactClass (CedarProps state action) -> (action -> EventHandler) -> state -> ReactElement
```

#### `ignore`

``` purescript
ignore :: forall state action. ReactClass (CedarProps state action) -> state -> Array ReactElement -> ReactElement
```

#### `ignore'`

``` purescript
ignore' :: forall state action. ReactClass (CedarProps state action) -> state -> ReactElement
```


