{-# LANGUAGE DeriveGeneric #-}

module Command
  ( CommandType(..)
  , ResultType(..)
  ) where

import Data.Binary
import GHC.Generics

data CommandType = Insert String String
                 | Delete String
                 | Set    String String
                 | Get    String
  deriving (Show, Read, Generic)

instance Binary CommandType

data ResultType = Success String String String     -- for successful Get, Insert, Delete, Set
                | Failure String String String
  deriving (Show, Read, Generic)

instance Binary ResultType
