module View.AJAX (routeAJAX) where

import Happstack.Server           ( dir
                                  , ok
                                  , path
                                  , toResponse
                                  , Response
                                  , ServerPart )
import Control.Monad              ( msum       )
import Control.Monad.IO.Class     ( liftIO     )
import Data.ByteString.Lazy.Char8 ( unpack )

import qualified BirdData.JSON as BirdJSON

routeAJAX = msum [
                   dir "fetch-bird" (path fetchBird)
                 ]

fetchBird :: String -> ServerPart Response
fetchBird birdName = do
    json <- liftIO $ BirdJSON.getBirdJSON birdName
    ok . toResponse $ case json of
        Left err -> "{ error: \"" ++ err ++ "\"; }"
        Right j -> unpack j
