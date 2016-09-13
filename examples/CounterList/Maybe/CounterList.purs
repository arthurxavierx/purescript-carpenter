module Examples.CounterList.Maybe.CounterList where

import Prelude
import Carpenter (Render, Update, spec)
import Carpenter.Cedar (watch')
import Data.Array (updateAt, mapWithIndex, snoc, deleteAt)
import Data.Maybe (Maybe(..), fromMaybe)
import Examples.CounterList.Maybe.Counter (Counter, counter)
import React (ReactClass, createClass)
import React.DOM (text, button, div')
import React.DOM.Props (onClick)

type CounterList = Array Counter

data CounterListAction = Add | UpdateCounter Int Counter

counterListClass :: ReactClass _
counterListClass = createClass $ spec [Just 0] update render

update :: forall props eff. Update CounterList props CounterListAction eff
update yield action _ _ =
  case action of
    Add ->
      yield \state -> snoc state (Just 0)
    UpdateCounter i counter ->
      case counter of
        Just c ->
          yield \state -> fromMaybe state $ updateAt i counter state
        Nothing ->
          yield \state -> fromMaybe state $ deleteAt i state

render :: forall props. Render CounterList props CounterListAction
render dispatch _ state _ =
  div'
    [ div' $ mapWithIndex (\i c -> watch' counter (dispatch <<< UpdateCounter i) c) state
    , button [onClick \_ -> dispatch Add] [text "++"]
    ]
