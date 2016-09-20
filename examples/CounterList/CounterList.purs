module Examples.CounterList.CounterList where

import Prelude
import Carpenter (Render, Update, spec)
import Carpenter.Cedar (capture')
import Data.Array (mapWithIndex, snoc, deleteAt)
import Data.Maybe (fromMaybe)
import Examples.CounterList.Counter (counterComponent, CounterAction(Remove), Counter)
import React (ReactClass, createClass)
import React.DOM (text, button, div')
import React.DOM.Props (onClick)

type CounterList = Array Counter

data CounterListAction = Add | CounterAction Int CounterAction

counterListComponent :: ReactClass _
counterListComponent = createClass $ spec [0] update render

update :: forall props eff. Update CounterList props CounterListAction eff
update yield _ action _ state =
  case action of
    Add ->
      yield \s -> snoc s 0
    CounterAction i Remove ->
      yield \s -> fromMaybe s $ deleteAt i s
    CounterAction _ _ ->
      pure state

render :: forall props. Render CounterList props CounterListAction
render dispatch _ state _ =
  div'
    [ div' $ mapWithIndex (\i c -> capture' counterComponent (dispatch <<< CounterAction i) c) state
    , button [onClick \_ -> dispatch Add] [text "++"]
    ]
