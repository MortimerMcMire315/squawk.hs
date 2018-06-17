{-# LANGUAGE DeriveGeneric #-}
module ORM.ORMTest (Localbird(..), createTable) where

import Data.Text ( Text )
import qualified Data.Text as T
--import Database.PostgreSQL.ORM.Association
import Database.PostgreSQL.ORM.CreateTable
import Database.PostgreSQL.ORM.Model
import Data.ByteString.Char8 ( ByteString )
import qualified Data.ByteString.Char8 as BS
--import Database.PostgreSQL.ORM.DBSelect
import Database.PostgreSQL.Simple
--import Database.PostgreSQL.Devel
import GHC.Generics

--import Control.Applicative
--import Data.GetField

data Localbird =
  Localbird { id            :: !DBKey
            , name          :: String
            , thumbnailPath :: String
            , callPath      :: String
            , info          :: Text
            } deriving (Show, Eq, Generic)

instance Model Localbird

connstr :: BS.ByteString
connstr = BS.pack "host=localhost user=squawk password=squawk port=5432 dbname=squawk"

conn :: IO Connection
conn = connectPostgreSQL connstr

createTable :: IO ()
createTable = do
    c <- conn
    let birb = Localbird (DBKey 4) "Blackbird" "/yo" "/yo/no" (T.pack "It's a bird, dummy.")
    res <- modelCreate c birb
    return ()
