module DB.Conn
    ( getConn
    ) where

import Database.PostgreSQL.Simple ( Connection
                                  , connect            )
import Config ( CfgData (..)
              , parseConfig )

-- |Try to connect to a PostgreSQL database by parsing the user's config file.
--  Returns either an error string or a connection.
getConn :: CfgData -> IO Connection
getConn = connect . dbInfo
