module Examples.CounterList.Counter where

import Prelude
import Carpenter (Render, Update)
import Carpenter.Cedar (CedarClass, cedarSpec)
import React (createClass)
import React.DOM (button, div', text, h1')
import React.DOM.Props (onClick)

type Counter = Int

data CounterAction = Increment | Decrement | Remove

counterComponent :: CedarClass Counter CounterAction
counterComponent = createClass $ cedarSpec update render

update :: forall props eff. Update Counter props CounterAction eff
update yield _ action _ state =
  case action of
    Increment ->
      yield (_ + 1)
    Decrement ->
      yield (_ - 1)
    Remove ->
      pure state

render :: forall props. Render Counter props CounterAction
render dispatch _ state _ =
  div'
    [ h1' [text (show state)]
    , button [onClick \_ -> dispatch Increment] [text "+"]
    , button [onClick \_ -> dispatch Decrement] [text "-"]
    , button [onClick \_ -> dispatch Remove] [text "X"]
    ]
