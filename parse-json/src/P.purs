module P (module X) where

import Text.Parsing.Parser.String (whiteSpace, char, string, satisfy, eof) as X
import Text.Parsing.Parser.Combinators (sepBy, between, choice) as X
