module Test.Counters where

import Prelude
import Carpenter (Update, Render, ActionHandler)
import Carpenter.Cedar (CedarClass, spec, capture')
import Data.Array (mapWithIndex, snoc, deleteAt)
import Data.Maybe (fromMaybe)
import React (ReactElement, createClass)
import React.DOM (button, div', text, span')
import React.DOM.Props (onClick)

type Counter = Int
data CounterAction = Increment | Decrement | Remove

updateCounter :: ∀ props eff. Update Counter props CounterAction eff
updateCounter yield action _ _ =
  case action of
    Increment ->
      yield (_ + 1)
    Decrement ->
      yield (_ - 1)
    Remove ->
      yield id

renderCounter :: ∀ props. Render Counter props CounterAction
renderCounter dispatch _ state =
  div'
    [ span' [text (show state)]
    , button [onClick \_ -> dispatch Increment] [text "+"]
    , button [onClick \_ -> dispatch Decrement] [text "-"]
    , button [onClick \_ -> dispatch Remove] [text "X"]
    ]

counterClass :: CedarClass Counter CounterAction
counterClass = createClass $ spec updateCounter renderCounter

counter :: ActionHandler CounterAction -> Counter -> ReactElement
counter = capture' counterClass

--
type CounterList = Array Counter
data CounterListAction = Add | CounterAction Int CounterAction

updateCounterList :: ∀ props eff. Update CounterList props CounterListAction eff
updateCounterList yield action _ _ =
  case action of
    Add ->
      yield \state -> snoc state 0
    CounterAction i caction ->
      case caction of
        Remove ->
          yield \state -> fromMaybe state $ deleteAt i state
        _ ->
          yield id

renderCounterList :: ∀ props. Render CounterList props CounterListAction
renderCounterList dispatch _ state =
  div'
    [ div' $ mapWithIndex (\i c -> counter (dispatch <<< CounterAction i) c) state
    , button [onClick \_ -> dispatch Add] [text "++"]
    ]

counterListClass :: CedarClass CounterList CounterListAction
counterListClass = createClass $ spec updateCounterList renderCounterList
