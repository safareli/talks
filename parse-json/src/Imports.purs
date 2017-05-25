module Imports ( module X, module Imports ) where

import Data.String (fromCharArray)
import Data.Identity (Identity)
import Data.Int (fromStringAs, Radix)
import Text.Parsing.Parser (ParserT)

import Prelude hiding (between) as X
import Data.Int (hexadecimal) as X
import Control.Alt ((<|>)) as X
import Control.Alternative (empty) as X
import Control.Apply (lift2) as X
import Control.Lazy (defer) as X
import Data.Array (range, some, many) as X
import Data.Char.Unicode (isControl, isHexDigit) as X
import Data.Enum (toEnum) as X
import Data.Foldable (fold) as X
import Data.Generic.Rep (class Generic) as X
import Data.Generic.Rep.Show (genericShow) as X
import Data.Identity (Identity) as X
import Data.List (List) as X
import Data.Maybe (Maybe)
import Data.Maybe (Maybe, maybe) as X
import Data.Tuple (Tuple(..)) as X
import Data.Unfoldable (class Unfoldable, replicateA) as X
import Global (readFloat) as X

intFromStringAs ∷ Radix → String → Maybe Int
intFromStringAs = fromStringAs

stringFromCharArray ∷ Array Char → String
stringFromCharArray = fromCharArray

type Parser a = ParserT String Identity a
