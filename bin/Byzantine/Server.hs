module Main
  ( main
  ) where

import Network.Tangaroa.Byzantine.Spec.Simple

import Data.IORef
import Data.Map (Map)
import qualified Data.Map as Map

import Command

applyCommand :: IORef (Map String String) -> CommandType -> IO ResultType
applyCommand ref cmd =
  case cmd of
    Insert k v -> runInsert ref k v
    Delete k   -> runDelete ref k
    Set    k v -> runSet    ref k v
    Get    k   -> runGet    ref k

member :: IORef (Map String String)
       -> String
       -> (IORef (Map String String) -> IO ResultType)
       -> (IORef (Map String String) -> IO ResultType)
       -> IO ResultType
member ref k memberFn notMemberFn = do
  isMember <- Map.member k <$> readIORef ref
  if isMember
    then memberFn ref
    else notMemberFn ref

-- adds a new mapping, and fails if a mapping already exists
runInsert :: IORef (Map String String) -> String -> String -> IO ResultType
runInsert ref k v = member ref k (doFail "runInsert" k v) (doInsert k v)

-- like insert, but instead fails if a mapping doesn't exist
runSet :: IORef (Map String String) -> String -> String -> IO ResultType
runSet ref k v = member ref k (doInsert k v) (doFail "runSet" k v)

-- gets the value for a key, fails if it doesn't exist
runGet :: IORef (Map String String) -> String -> IO ResultType
runGet ref k = do
  mv <- Map.lookup k <$> readIORef ref
  case mv of
    Just v  -> return (Success "Get" k v)
    Nothing -> return (Failure "Get" k "")

-- removes the mapping for a key, fails if it doesn't exist
runDelete :: IORef (Map String String) -> String -> IO ResultType
runDelete ref k = member ref k (doDelete k) (doFail "runDelete" k "")

doFail :: String -> String -> String -> IORef (Map String String) -> IO ResultType
doFail op k v = return . const (Failure op k v)

doInsert :: String -> String -> IORef (Map String String) -> IO ResultType
doInsert k v ref = modifyIORef ref (Map.insert k v) >> return (Success "Insert" k v)

doDelete :: String -> IORef (Map String String) -> IO ResultType
doDelete k ref = modifyIORef ref (Map.delete k) >> return (Success "Delete" k "")

main :: IO ()
main = do
  stateVariable <- newIORef Map.empty
  runServer (applyCommand stateVariable)
