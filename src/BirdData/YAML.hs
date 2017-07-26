{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module BirdData.YAML (module BirdData.YAML) where

import qualified Data.Yaml as Y
import Prelude hiding  ( readFile )
import Data.Yaml       ( FromJSON(..), (.:) )
import Data.ByteString ( readFile
                       , ByteString )

data BirdCategory =
        BirdCategory {
          category :: String
        , birdNames :: [String]
        } deriving (Eq, Show)

instance FromJSON BirdCategory where
    parseJSON (Y.Object v) = BirdCategory
        <$> v .: "category"
        <*> v .: "birds"
    parseJSON _ = fail "YAML shat the bed."

birdYAML :: IO ByteString
birdYAML = readFile "birdlist.yaml"

getBirdNames :: IO (Maybe [BirdCategory])
getBirdNames = Y.decode <$> birdYAML
