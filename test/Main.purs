module Test.Main where

import Prelude
import React.Cedar (Update)

type State = Int

data Action = Increment | Decrement

update :: ∀ props eff. Update State props Action eff
update yield action props state =
  case action of
    Increment ->
      yield (_ + 1)
    Decrement ->
      yield (_ - 1)

