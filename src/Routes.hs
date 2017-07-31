module Routes
    ( routes
    ) where

import Happstack.Server
import Control.Monad      ( msum )

import qualified View.Views as Views
import qualified View.AJAX  as AJAX

myPolicy :: BodyPolicy
myPolicy = defaultBodyPolicy "/tmp/" 0 1000 1000

routes = do
    decodeBody myPolicy
    msum [
           dir "css"    Views.serveCSS
         , dir "js"     Views.serveJS
         , dir "ajax"   AJAX.routeAJAX
         , nullDir   >> Views.homePage
         ]
