{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
module BirdData.ParseJSON (getBirdInfo) where

import Text.Printf                   ( printf     )
import Network.Wreq                  ( get
                                     , responseBody
                                     , responseStatus
                                     , statusCode )
import Control.Lens                  ( (^.)       )
import Text.Regex.PCRE.Heavy         ( sub, re    )
import Data.ByteString.Lazy.Internal ( ByteString )
import Data.Aeson.Types              ( parseEither
                                     , Parser
                                     , Value      )
import Data.Aeson                    ( eitherDecode
                                     , withObject
                                     , (.:)       )

import BirdData.Bird ( Bird )

getBirdList :: Value -> Parser [Bird]
getBirdList val = do
    res <- (withObject "res" $ \o -> o .: "response") val :: Parser Value
    (withObject "birds" $ \o -> o .: "docs") res

reqURL = "https://solr.allaboutbirds.net/solr/speciesGuide/select?defType=edismax&json.wrf=angular.callbacks._1&q=%s&rows=5&wt=json"

jsonToBird :: ByteString -> Either String [Bird]
jsonToBird json = parseEither getBirdList =<< eitherDecode json

getBirdInfo :: String -> IO (Either String [Bird])
getBirdInfo name = do
    let completeURL = printf reqURL name
    res <- get completeURL
    if (res ^. responseStatus . statusCode) /= 200
    then return $ Left "Error: Bird not found."
    else do
        {-- The response looks like:
         -      angular.callbacks._1({a bunch of json data})
         -  so we have to extract everything between the parentheses.
         -  PCRE has lazy (ungreedy) quantifiers, i.e. *?
         -  https://regex101.com/r/0mgbKM/1                      --}
        let json = sub [re|.*?\((.*)\)|] (\(m:_) -> m :: String) (res ^. responseBody)
        -- I want empty JSON to be an error.
        return $ case jsonToBird json of
            Right [] -> Left "Error: Bird not found."
            x        -> x
