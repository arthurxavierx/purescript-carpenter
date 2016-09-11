module Test.Main where

import Prelude
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (log, CONSOLE)
import React.Carpenter (Update)

type State = Int

data Action = Increment | Decrement

update :: ∀ props eff. Update State props Action (console :: CONSOLE | eff)
update yield action props state =
  case action of
    Increment -> do
      liftEff $ log "Incrementing"
      yield (_ + 1)
    Decrement -> do
      liftEff $ log "Decrementing"
      yield (_ - 1)

