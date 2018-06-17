{-# LANGUAGE FlexibleContexts #-}

module Config ( parseConfig
              , CfgData (..)
              ) where

import Data.ConfigFile        ( readfile
                              , get
                              , emptyCP
                              , CPError(..)
                              , CPErrorData(..) )

import Control.Monad.IO.Class ( liftIO          )
import Control.Monad.Except   ( runExceptT      )
import Control.Monad.Catch    ( throwM
                              , MonadThrow      )
import Control.Monad          ( join            )
import Database.PostgreSQL.Simple ( ConnectInfo (..))


data CfgData = CfgData { dbInfo :: ConnectInfo
                       , dataDir :: FilePath
                       }

-- |Attempt to parse the configuration file located in conf/sparkive.conf.
parseConfig' :: IO (Either CPError CfgData)
parseConfig' = runExceptT $ do
    cp <- join . liftIO $ readfile emptyCP "squawk.ini"
    ci_hs <- get cp "Postgres" "host"
    ci_us <- get cp "Postgres" "user"
    ci_ps <- get cp "Postgres" "pass"
    ci_pt <- get cp "Postgres" "port"
    ci_nm <- get cp "Postgres" "dbname"
    dd <- get cp "Data" "datadir"

    return $ CfgData (ConnectInfo ci_hs ci_pt ci_us ci_ps ci_nm)
                     dd

-- |Parse the configuration file as in 'parseConfig\'', but simply return Either
--  if an error occurs.
parseConfig :: IO CfgData
parseConfig = do pc <- parseConfig'
                 case pc of
                    Left e -> error $ prettyPrintErr e
                    Right x -> return x


-- |Return a string describing the given 'CPError' in a more user-friendly way.
prettyPrintErr :: CPError -> String
prettyPrintErr (errDat,errStr) =
    case errDat of
        ParseError str -> "The " ++ confFile ++ " appears to be malformed. Here's the parse error: " ++ str
        NoSection str -> "The section \"" ++ str ++ "\" does not exist in the " ++ confFile ++ "."
        NoOption str -> "The option \"" ++ str ++ "\" does not exist in the " ++ confFile ++ "."
        OtherProblem str -> "There was an error processing the " ++ confFile ++ ". Here's the error: " ++ str
        _ -> error "Could not process configuration file."

    where confFile = "configuration file for this Squawk installation (squawk.ini)"
