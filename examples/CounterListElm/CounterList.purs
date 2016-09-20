module Examples.CounterListElm.CounterList where

import Prelude
import Examples.CounterListElm.Counter as Counter
import Carpenter (Render, Update, spec)
import Data.Array (mapWithIndex, mapMaybe, snoc)
import Data.Maybe (Maybe(Just))
import Examples.CounterListElm.Counter (CounterAction, Counter)
import React (ReactClass, createClass)
import React.DOM (text, button, div')
import React.DOM.Props (onClick)

type CounterList = Array Counter

data CounterListAction = Add | UpdateCounter Int CounterAction

counterListClass :: ReactClass _
counterListClass = createClass $ spec [0] update render

update :: forall props eff. Update CounterList props CounterListAction eff
update yield _ action _ _ =
  case action of
    Add ->
      yield \state -> snoc state 0

    UpdateCounter i caction -> do
      yield $ mapMaybe id <<< mapWithIndex (updateCounter i caction)

  where
    updateCounter id caction i counter
      | id == i   = Counter.update caction counter
      | otherwise = Just counter

render :: forall props. Render CounterList props CounterListAction
render dispatch _ state _ =
  div'
    [ div' $ mapWithIndex (\i c -> Counter.render (dispatch <<< UpdateCounter i) c) state
    , button [onClick \_ -> dispatch Add] [text "++"]
    ]
