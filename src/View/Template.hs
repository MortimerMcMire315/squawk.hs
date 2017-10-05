{-# LANGUAGE TemplateHaskell #-}
module View.Template (module View.Template) where

import Text.Hamlet       ( shamletFile
                         , Html             )
import Text.Blaze.Html   ( preEscapedToHtml )

import View.TemplateUtil ( hamFile
                         , cssFile
                         , jsFile           )

import BirdData.YAML     ( birdNames
                         , category
                         , getBirdNames
                         , BirdCategory     )

footerT :: Html
footerT = $(shamletFile $ hamFile "footer")

headerT :: Html
headerT = $(shamletFile $ hamFile "header")

homePageT :: [BirdCategory] -> Html
homePageT birdCatLs = $(shamletFile $ hamFile "home")

categorySelectT :: [BirdCategory] -> Html
categorySelectT birdCatLs = $(shamletFile $ hamFile "categorySelect")
