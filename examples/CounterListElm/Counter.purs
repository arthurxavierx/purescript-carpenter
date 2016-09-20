module Examples.CounterListElm.Counter where

import Prelude
import Carpenter (Dispatcher)
import Data.Maybe (Maybe(..))
import React (ReactElement)
import React.DOM (button, div', text, h1')
import React.DOM.Props (onClick)

type Counter = Int

data CounterAction = Increment | Decrement | Remove

update :: CounterAction -> Counter -> Maybe Counter
update action state =
  case action of
    Increment ->
      Just (state + 1)
    Decrement ->
      Just (state - 1)
    Remove ->
      Nothing

render :: Dispatcher CounterAction -> Counter -> ReactElement
render dispatch state =
  div'
    [ h1' [text (show state)]
    , button [onClick \_ -> dispatch Increment] [text "+"]
    , button [onClick \_ -> dispatch Decrement] [text "-"]
    , button [onClick \_ -> dispatch Remove] [text "X"]
    ]
