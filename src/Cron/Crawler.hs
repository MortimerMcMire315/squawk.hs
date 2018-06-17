{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Cron.Crawler where

import BirdData.YAML          ( getBirdNames
                              , BirdCategory (..)  )
import BirdData.Bird          ( normalizeBirdName  )
import DB.Conn                ( getConn            )
import Config                 ( parseConfig
                              , CfgData (..)       )


import Control.Monad          ( void               )
import Database.PostgreSQL.ORM.CreateTable
import Database.PostgreSQL.ORM.Model
import Database.PostgreSQL.ORM.DBSelect
import Database.PostgreSQL.Simple

import Data.String            ( fromString         )

import GHC.Generics           ( Generic            )
import Control.Exception.Base ( Exception
                              , displayException
                              , catch              )
import Data.Text              ( Text, pack         )
import Data.Int               ( Int64              )

import System.Directory       ( doesDirectoryExist )

{-# ANN module ("HLint: ignore Use camelCase" :: String) #-}
data Localbird =
  Localbird { id              :: !DBKey
            , name            :: String
            , normalized_name :: String
            , thumbnail_path  :: String
            , callPath        :: String
            , info            :: Text
            , categoryid      :: !(GDBRef NormalRef Category)
            } deriving (Show, Generic)

instance Model Localbird

emptyBird = Localbird NullKey "" "" "" "" (pack "") (DBRef 0)


data Category =
    Category { id              :: !DBKey
             , name            :: String
             , normalized_name :: String
             } deriving (Show, Generic)
instance Model Category

emptyCategory = Category NullKey "" ""

addDBRowIfNotExists :: forall a. Model a => Connection -> String -> String -> a -> IO a
addDBRowIfNotExists conn searchColumn searchKey modelToAdd = do
    -- The 'a' at the end of the last type annotation in the following line refers
    -- to the same 'a' in the function's type annotation, using Scoped Type Variables.
    matches <- dbSelect conn $ addWhere (fromString $ searchColumn ++ " = ?" :: Query) (Only searchKey) (modelDBSelect :: DBSelect a)
    if null matches
    then save conn modelToAdd
    else getModelFromDB conn matches searchColumn searchKey

getModelFromDB :: (Model a) => Connection -> [a] -> String -> String -> IO a
getModelFromDB conn matches searchColumn searchKey
    | length matches > 1 = error $ "Multiple matches for " ++ searchColumn ++ ": " ++ searchKey
    | otherwise = return $ head matches

downloadBirdInfo :: Connection -> Category -> String -> IO ()
downloadBirdInfo conn category birdName =
    let normalized = normalizeBirdName birdName in void $
        addDBRowIfNotExists conn "normalized_name" normalized
            (Localbird NullKey birdName normalized "" "" "It's a bird." $ mkDBRef category)

downloadBirdCategory :: Connection -> BirdCategory  -> IO ()
downloadBirdCategory conn bc = do
    let catName = category bc
    let normalizedCatName = normalizeBirdName catName
    catRow <- addDBRowIfNotExists conn "normalized_name" normalizedCatName (Category NullKey catName  normalizedCatName)
    mapM_ (downloadBirdInfo conn catRow) $ birdNames bc

createTables :: CfgData -> IO Int64
createTables cfg = do
    conn <- getConn cfg
    let birb = emptyBird
    let cat = emptyCategory
    modelCreate conn cat
    modelCreate conn birb

crawl :: IO ()
crawl = do cfg <- parseConfig
           --createTables cfg
           maybeBirdCats <- getBirdNames
           conn <- getConn cfg
           case maybeBirdCats of
                Nothing -> error "Could not parse YAML."
                Just bc -> mapM_ (downloadBirdCategory conn) bc
