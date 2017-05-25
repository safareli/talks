module Main where
import Imports
import P as P

data JValue
  = JNull
  | JBool   Boolean
  | JNumber Number
  | JString String
  | JArray  (List JValue)
  | JObject (List (Tuple String JValue))


derive instance genericJValue ∷ Generic JValue _
instance showJValue ∷ Show JValue where
  show a = genericShow a


value ∷ Parser JValue
value = P.whiteSpace *> jValue <* P.eof

jValue ∷ Parser JValue
jValue = P.choice
  [ jString
  , jNumber
  , defer \_ → jObject
  , defer \_ → jArray
  , jBool
  , jNull
  ]

jObject ∷ Parser JValue
jObject = map JObject (commaSeparated '{' '}' field)
  where
  field ∷ Parser (Tuple String JValue)
  field = lift2 Tuple (string <* tokC ':') (defer \_ → jValue)

jArray ∷ Parser JValue
jArray = map JArray (commaSeparated '[' ']' (defer \_ → jValue))

jBool ∷ Parser JValue
jBool = map JBool (tok (P.choice
  [ (P.string "true" $> true)
  , (P.string "false" $> false)
  ]))

jNull ∷ Parser JValue
jNull = tok (P.string "null") $> JNull

jString ∷ Parser JValue
jString = map JString string

string ∷ Parser String
string = P.between (P.char '"') (tokC '"') (map stringFromCharArray (many char))
  where
  char ∷ Parser Char
  char = P.choice [unescaped, escaped]

  unescaped ∷ Parser Char
  unescaped = P.satisfy isUnescaped

  isUnescaped ∷ Char → Boolean
  isUnescaped x = not (x == '"' || x == '\\' || isControl x)

  escaped ∷ Parser Char
  escaped = (P.char '\\') *> (P.choice
    [ P.char '"'
    , P.char '\\'
    , P.char '/'
    , P.char 'b'  $> '\b'
    , P.char 'f'  $> '\f'
    , P.char 'n'  $> '\n'
    , P.char 'r'  $> '\r'
    , P.char 't'  $> '\t'
    , P.char 'u'  *> unicode
    ])

  unicode ∷ Parser Char
  unicode = unicodeHexCode >>= hexCodeToChar

  unicodeHexCode ∷ Parser String
  unicodeHexCode = map stringFromCharArray (replicateA 4 hexDigit)

  hexDigit ∷ Parser Char
  hexDigit = P.satisfy isHexDigit

  hexCodeToChar ∷ String → Parser Char
  hexCodeToChar cs = maybe empty pure (hexCodeToMaybeChar cs)

  hexCodeToMaybeChar ∷ String → Maybe Char
  hexCodeToMaybeChar cs = hexCharsToInt cs >>= toEnum

  hexCharsToInt ∷ String → Maybe Int
  hexCharsToInt cs = intFromStringAs hexadecimal cs


jNumber ∷ Parser JValue
jNumber = map stringToJNumber (tok number)

stringToJNumber ∷ String → JValue
stringToJNumber n = JNumber (readFloat n)

number ∷ Parser String
number = fold [sign, integer, fractional, exponential]

sign ∷ Parser String
sign = P.string "-" <|> pure ""

integer ∷ Parser String
integer = int 0 <|> fold [ digit1_9, manyDigits ]

fractional ∷ Parser String
fractional = fold [ P.string ".",  someDigits] <|> pure ""

someDigits ∷ Parser String
someDigits = map fold (some digit)

manyDigits ∷ Parser String
manyDigits = map fold (many digit)

exponential ∷ Parser String
exponential =  fold [ exponentialE, exponentialSign, someDigits ] <|> pure ""

exponentialE ∷ Parser String
exponentialE = P.string "e" <|> P.string "E"

exponentialSign ∷ Parser String
exponentialSign = P.string "+" <|> sign

digit ∷ Parser String
digit = int 0 <|> digit1_9

digit1_9 ∷ Parser String
digit1_9 = P.choice (map int (range 1 9))

int ∷ Int → Parser String
int n = P.string (show n)


commaSeparated ∷ ∀ a . Char → Char → Parser a → Parser (List a)
commaSeparated open close p = (P.between (tokC open) (tokC close) (p `P.sepBy` (tokC ',')))

tokC ∷ Char → Parser Char
tokC c = tok (P.char c)

tok ∷ ∀ a. Parser a → Parser a
tok p = p <* P.whiteSpace
