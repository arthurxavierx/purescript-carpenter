module Examples.CounterList.CounterList where

import Prelude
import Carpenter (Render, Update, spec)
import Data.Array (mapWithIndex, snoc, deleteAt)
import Data.Maybe (fromMaybe)
import Examples.CounterList.Counter (counter, CounterAction(Remove), Counter)
import React (ReactClass, createClass)
import React.DOM (text, button, div')
import React.DOM.Props (onClick)

type CounterList = Array Counter

data CounterListAction = Add | CounterAction Int CounterAction

counterListClass :: ReactClass _
counterListClass = createClass $ spec [0] update render

update :: forall props eff. Update CounterList props CounterListAction eff
update yield action _ _ =
  case action of
    Add ->
      yield \state -> snoc state 0
    CounterAction i caction ->
      case caction of
        Remove ->
          yield \state -> fromMaybe state $ deleteAt i state
        _ ->
          yield id

render :: forall props. Render CounterList props CounterListAction
render dispatch _ state _ =
  div'
    [ div' $ mapWithIndex (\i c -> counter (dispatch <<< CounterAction i) c) state
    , button [onClick \_ -> dispatch Add] [text "++"]
    ]
