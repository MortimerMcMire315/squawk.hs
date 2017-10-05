{-# LANGUAGE ScopedTypeVariables #-}

module View.Views
    ( homePage
    , serveCSS
    , serveJS
    ) where


import Happstack.Server ( notFound
                        , nullDir
                        , ok
                        , path
                        , toResponse
                        , ServerPart
                        , ToMessage
                        , Response  )

import View.TemplateUtil ( jsFile, cssFile )
import View.ContentTypes ( toResMime
                         , MIMEType (JS, CSS, HTML) )

import Control.Monad.IO.Class ( liftIO   )
import Data.Maybe             ( fromJust )
import Data.Text.Lazy.IO      ( readFile )
import Prelude hiding         ( readFile )


import qualified View.Template as Template
import qualified BirdData.JSON as BirdJSON
import qualified BirdData.YAML as YAML

serveCSS :: ServerPart Response
serveCSS = path $ \(cssRequest :: String) ->
                case cssRequest of
                    "styles.css"    -> doServe "styles"
                    "normalize.css" -> doServe "normalize"
                    _               -> notFound $ toResponse ("CSS stylesheet not found." :: String)
    where doServe name = (liftIO . readFile . cssFile) name >>= nullDirServe CSS

serveJS :: ServerPart Response
serveJS = path $ \(jsRequest :: String) ->
             case jsRequest of
                "main.js"    -> doServe "main"
                _            -> notFound $ toResponse ("JavaScript file not fouund." :: String)
    where doServe name = (liftIO . readFile . jsFile) name >>= nullDirServe JS


-- |Make sure the request is sane (no path segments after *.css or *.js or
--  whatever); if so, serve the file with a MIME type, like "text/css"
nullDirServe :: (ToMessage t) => MIMEType -> t -> ServerPart Response
nullDirServe mimeT template = nullDir >> ok (toResMime template mimeT)

homePage :: ServerPart Response
homePage = do
    birdList <- liftIO YAML.getBirdNames
    birdInfo <- liftIO $ BirdJSON.getBirdObject "Blackbird"
    liftIO $ print birdInfo
    ok . toResponse . Template.homePageT $ fromJust birdList
