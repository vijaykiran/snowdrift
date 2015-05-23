module Api.Root where

import Import

import Control.Monad.Trans.Resource
import Data.Aeson
import Data.Conduit
import qualified Data.Conduit.Attoparsec as CA
import qualified Data.Conduit.Combinators as CC
import Data.Default (def)
import Data.FileEmbed
import qualified Data.Text.Encoding as TE
import qualified Data.Text.Lazy as TL
import Text.Markdown (markdown)

getApiRootR :: Handler Html
getApiRootR =
  defaultLayout
    (do let markdownBytes = $(embedFile "API.md")
            markdownText =
              TL.fromStrict (TE.decodeUtf8 markdownBytes)
            htmlText = markdown def markdownText
        toWidget htmlText)

postApiRootR :: Handler RepJson
postApiRootR =
  do jsonValue <-
       connect rawRequestBody (CA.sinkParser json)
     fmap repJson
          (respondSource typeJson
                         (sendChunkLBS (encode jsonValue)))
