module Examples.CounterList.Maybe.Counter where

import Prelude
import Carpenter (Render, Update)
import Carpenter.Cedar (CedarClass, cedarSpec)
import Data.Maybe (Maybe(..))
import React (createClass)
import React.DOM (button, div', text, span')
import React.DOM.Props (onClick)

type Counter = Maybe Int

data CounterAction = Increment | Decrement | Remove

counter :: CedarClass Counter CounterAction
counter = createClass $ cedarSpec update render

update :: forall props eff. Update Counter props CounterAction eff
update yield _ action _ _ =
  case action of
    Increment ->
      yield $ map (_ + 1)
    Decrement ->
      yield $ map (_ - 1)
    Remove ->
      yield $ const Nothing

render :: forall props. Render Counter props CounterAction
render dispatch _ state _ =
  div'
    [ span' [text (show state)]
    , button [onClick \_ -> dispatch Increment] [text "+"]
    , button [onClick \_ -> dispatch Decrement] [text "-"]
    , button [onClick \_ -> dispatch Remove] [text "X"]
    ]
