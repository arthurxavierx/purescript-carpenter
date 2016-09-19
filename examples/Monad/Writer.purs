module Examples.Monad.Writer where

import Prelude
import React.DOM as R
import React.DOM.Props as P
import Carpenter (spec, Update, Render)
import Control.Monad.Writer (execWriter, Writer, tell)
import React (createClass, ReactClass)

type Counter = Writer String Unit

writerComponent :: forall props. ReactClass props
writerComponent = createClass $ spec (pure unit) update render

update :: forall props eff. Update Counter props Counter eff
update yield _ action _ _ = yield (_ *> action)

render :: forall props. Render Counter props Counter
render dispatch _ state _ =
  R.div'
    [ R.h1' [R.text (show $ execWriter state)]
    , R.button [P.onClick \_ -> dispatch (tell "1")] [R.text "+1"]
    , R.button [P.onClick \_ -> dispatch (tell "5")] [R.text "+5"]
    ]
