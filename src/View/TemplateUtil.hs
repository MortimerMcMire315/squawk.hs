module View.TemplateUtil ( hamFile
                         , cssFile
                         , jsFile
                         ) where

-- |Given x, return the string "template/hamlet/x.hamlet
hamFile name = "template/hamlet/" ++ name ++ ".hamlet"
-- |Given x, return the string "template/lucius/x.css
cssFile name = "template/css/" ++ name ++ ".css"

-- |Given x, return the string "template/lucius/x.js
jsFile name = "template/js/" ++ name ++ ".js"
