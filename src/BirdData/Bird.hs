{-# LANGUAGE OverloadedStrings #-}
module BirdData.Bird ( Bird (..)
                     , normalizeBirdName ) where

import Data.Aeson       ( parseJSON
                        , withObject
                        , (.:)      )
import Data.Aeson.Types ( FromJSON  )
import Data.Text        ( replace
                        , toLower
                        , unpack
                        , pack      )

data Bird =
--  Bird { id           :: Int
  Bird { id           :: String
       , name         :: String
       , thumbnailUrl :: String
       , callUrl      :: String
       , infoUrl      :: String
       } deriving (Show, Eq)

instance FromJSON Bird where
    parseJSON = withObject "Bird" $ \v -> Bird
        -- <$> (read <$> v .: "id")
        <$> v .: "id"
        <*> v .: "title"
        <*> v .: "thumbnail"
        <*> v .: "profileSoundPath"
        <*> v .: "permalink"

normalizeBirdName :: String -> String
normalizeBirdName = unpack . toLower . replace "-" "" . replace " " "_" . replace "'" "" . replace "," "" . replace " and" "" . pack
