{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
module BirdData.JSON (getBirdObject, getBirdJSON) where

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
import Debug.Trace                   ( trace      )

import BirdData.Bird ( Bird )

parseBirdList :: Value -> Parser [Bird]
parseBirdList val = do
    res <- (withObject "res" $ \o -> o .: "response") val :: Parser Value
    (withObject "birds" $ \o -> o .: "docs") res

reqURL = "https://solr.allaboutbirds.net/solr/speciesGuide/select?defType=edismax&json.wrf=angular.callbacks._1&q=%s&rows=5&wt=json"

jsonToBird :: ByteString -> Either String [Bird]
jsonToBird json = parseEither parseBirdList =<< eitherDecode json

getBirdJSON :: String -> IO (Either String ByteString)
getBirdJSON name = do
    res <- get $ printf reqURL name
    return $ if (res ^. responseStatus . statusCode) /= 200
             then Left "Error: Bird not found."
             {-- The response looks like:
             -      angular.callbacks._1({a bunch of json data})
             -  so we have to extract everything between the parentheses.
             -  PCRE has lazy (ungreedy) quantifiers, i.e. *?
             -  https://regex101.com/r/0mgbKM/1                           --}
             else Right $ sub [re|.*?\((.*)\)|] (\(m:_) -> m :: String) (res ^. responseBody)

getBirdObject :: String -> IO (Either String [Bird])
getBirdObject name = do
        eitherjson <- getBirdJSON name
        return $
          eitherjson >>= (\json -> case jsonToBird json of
                             Right [] -> Left "error: Bird not found."
                             x        -> x
                         )
