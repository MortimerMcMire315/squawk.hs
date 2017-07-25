module Quiz.Bird (module Quiz.Bird) where

import Text.Printf  ( printf )
import Network.Wreq ( get
                    , responseBody
                    , responseStatus
                    , statusCode
                    )
import Control.Lens ( (^.) )

data Bird =
  Bird { name         :: String
       , thumbnailUrl :: String
       , callUrl      :: String
       , infoUrl      :: String
       } deriving (Show, Eq)

reqURL = "https://solr.allaboutbirds.net/solr/speciesGuide/select?defType=edismax&json.wrf=angular.callbacks._1&q=%s&rows=5&wt=json"

getBirdInfo :: String -> IO (Either String Bird)
getBirdInfo name = do
    let completeURL = printf reqURL name
    res <- get completeURL
    if (res ^. responseStatus . statusCode) /= 200
    then return $ Left "Error: Bird not found."
    else do
        let json = res ^. responseBody
        print json
        return . Right $ Bird "ayyy" "ayyy" "lmao" "lmao"
