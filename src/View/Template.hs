{-# LANGUAGE TemplateHaskell #-}
module View.Template (module View.Template) where

import Text.Hamlet       ( shamletFile
                         , Html              )
import Text.Lucius       ( luciusFile
                         , renderCss
                         , Css               )
import Text.Julius       ( juliusFile
                         , renderJavascriptUrl
                         , Javascript        )
import Text.Blaze.Html   ( preEscapedToHtml  )

import View.TemplateUtil ( hamFile
                         , cssFile
                         , jsFile            )

import BirdData.YAML     ( birdNames
                         , category
                         , getBirdNames
                         , BirdCategory      )

mainStyleSheet = renderCss $ $(luciusFile (cssFile "styles")) undefined
normalizeCSS   = renderCss $ $(luciusFile (cssFile "normalize")) undefined

mainJS = renderJavascriptUrl (\_ _ -> undefined) $(juliusFile (jsFile "main"))

footerT :: Html
footerT = $(shamletFile $ hamFile "footer")

headerT :: Html
headerT = $(shamletFile $ hamFile "header")

homePageT :: [BirdCategory] -> Html
homePageT birdCatLs = $(shamletFile $ hamFile "home")
