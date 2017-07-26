{-# LANGUAGE OverloadedStrings #-}
module BirdData.Bird (Bird (..)) where

import Data.Aeson ( parseJSON, withObject, (.:) )
import Data.Aeson.Types ( FromJSON )

data Bird =
  Bird { id           :: Int
       , name         :: String
       , thumbnailUrl :: String
       , callUrl      :: String
       , infoUrl      :: String
       } deriving (Show, Eq)

instance FromJSON Bird where
    parseJSON = withObject "Bird" $ \v -> Bird
        <$> (read <$> v .: "id")
        <*> v .: "title"
        <*> v .: "thumbnail"
        <*> v .: "profileSoundPath"
        <*> v .: "permalink"
