module Server (run) where

import Happstack.Server               ( simpleHTTP
                                      , nullConf      )
import Happstack.Server.ClientSession ( getDefaultKey
                                      , sessionPath
                                      , withClientSessionT
                                      , mkSessionConf )
import Routes                         ( routes        )

run :: IO ()
run = simpleHTTP nullConf routes
