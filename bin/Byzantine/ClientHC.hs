module Main
  ( main
  ) where

import Network.Tangaroa.Byzantine.Spec.Simple

import Command

import Data.IORef
import Control.Concurrent

getCommand :: IORef (Int, Int) -> IO CommandType
getCommand ref = do
  (i,j) <- readIORef ref
  threadDelay 15000 -- 1000000
  modifyIORef ref (\(i',j') -> (i'+1,j'))
  case i `mod` 5 of
    0 -> do modifyIORef ref (\(i',j') -> (i',j'+1))
            return (Insert (show $ j+1) (show $ j+1))
    1 -> return (Get    (show j))
    2 -> return (Set    (show j) (show (j*2)))
    3 -> return (Get    (show j))
    4 -> return (Delete (show j))
    _ -> return (Get    (show j))

showResult :: ResultType -> IO ()
showResult = print

main :: IO ()
main = do
  ref <- newIORef (0 :: Int, 0 :: Int)
  runClient (\_ -> return $ Failure "apply shuld not be called" "" "") (getCommand ref) showResult
