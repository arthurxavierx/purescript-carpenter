module Examples.CounterList.Counter where

import Prelude
import Carpenter (Render, Update, ActionHandler)
import Carpenter.Cedar (CedarClass, cedarSpec, capture')
import React (ReactElement, createClass)
import React.DOM (button, div', text, span')
import React.DOM.Props (onClick)

type Counter = Int

data CounterAction = Increment | Decrement | Remove

counter :: ActionHandler CounterAction -> Counter -> ReactElement
counter = capture' counterClass

counterClass :: CedarClass Counter CounterAction
counterClass = createClass $ cedarSpec update render

update :: forall props eff. Update Counter props CounterAction eff
update yield action _ _ =
  case action of
    Increment ->
      yield (_ + 1)
    Decrement ->
      yield (_ - 1)
    Remove ->
      yield id

render :: forall props. Render Counter props CounterAction
render dispatch _ state _ =
  div'
    [ span' [text (show state)]
    , button [onClick \_ -> dispatch Increment] [text "+"]
    , button [onClick \_ -> dispatch Decrement] [text "-"]
    , button [onClick \_ -> dispatch Remove] [text "X"]
    ]
