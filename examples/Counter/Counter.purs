module Examples.Counter.Counter where

import Prelude
import Carpenter (spec, Render, Update)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (log, CONSOLE)
import React (createClass, ReactClass)
import React.DOM (text, button, span', div')
import React.DOM.Props (onClick)

type State = Int

data Action = Init | Increment | Decrement

counterClass :: ReactClass _
counterClass = createClass $ spec 0 update render

update :: forall props eff. Update State props Action (console :: CONSOLE | eff)
update yield action _ _ =
  case action of
    Init -> do
      liftEff $ log "Initializing"
      yield (const 0)
    Increment -> do
      liftEff $ log "Incrementing"
      yield (_ + 1)
    Decrement -> do
      liftEff $ log "Decrementing"
      yield (_ - 1)

render :: forall props. Render State props Action
render dispatch _ state _ =
  div'
    [ span' [text (show state)]
    , button [onClick \_ -> dispatch Increment] [text "+"]
    , button [onClick \_ -> dispatch Decrement] [text "-"]
    ]
