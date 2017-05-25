module R
  ( module X
  , run
  ) where

import Prelude
import Imports as X
import Data.String (toLower) as X
import Control.Monad.Eff.Console (log) as X
import Text.Parsing.Parser (runParser, ParseError, parseErrorMessage, parseErrorPosition)
import Text.Parsing.Parser.Pos (Position(..))
import Data.Either (Either)
import Data.Bifunctor (lmap)


run ∷ ∀ a. String → X.Parser a  → Either String a
run s p = lmap printError (runParser s p)

printError ∷ ParseError  → String
printError err = parseErrorMessage err  <> "@" <> (printPosition $ parseErrorPosition err)

printPosition ∷ Position  → String
printPosition (Position {line, column}) = show line <> ":" <> show column
