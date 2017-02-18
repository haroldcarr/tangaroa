module Main (main) where

import           Codec.Crypto.RSA
import           Crypto.Random
import qualified Data.Map           as Map
import           Data.Word
import           Network.Socket
import           System.Directory
import           System.Environment
import           System.FilePath
import           System.IO
import           Text.Read

localhost :: HostAddress
localhost = 0x0100007f

portnums :: [Word16]
portnums = iterate (+ 1) 10000

usage :: String -> IO ()
usage msg = do
  putStrLn msg
  putStrLn "GenerateKeys [numKeys publicKeysFilename privateKeysDirectory]"

main :: IO ()
main = do
  g  <- newGenIO :: IO SystemRandom
  av <- getArgs
  case av of
    (numKeys : publicKeysFilename : privateKeysDirectory : [])
       -> main' g numKeys publicKeysFilename privateKeysDirectory
    [] -> do
      numKeys  <- promptAndGet "Number of keys to generate? "
      filename <- promptAndGet "Filename for public keys? "
      dirname  <- promptAndGet "Folder for private keys? "
      main' g numKeys filename dirname
    _ -> usage ""

promptAndGet :: String -> IO String
promptAndGet p = do
  putStrLn p
  hFlush stdout
  getLine

main' :: SystemRandom -> String -> FilePath -> FilePath -> IO ()
main' g numKeys publicKeysFilename privateKeysDirectory = do
  let nk = readMaybe numKeys
  case nk of
    Just n  -> do
      createDirectory privateKeysDirectory
      let keys = generateKeys g 1024 n
      writePublicKeys  publicKeysFilename   $ map fst keys
      writePrivateKeys privateKeysDirectory $ zip portnums $ map snd keys
    Nothing -> usage "error parsing numKeys"

generateKeys :: CryptoRandomGen g => g -> Int -> Int -> [(PublicKey, PrivateKey)]
generateKeys g nbits nkeys = case nkeys of
  0 -> []
  n -> (pubkey, privkey) : generateKeys ng nbits (n - 1) where
    (pubkey, privkey, ng) = generateKeyPair g nbits

writePublicKeys :: Show a => FilePath -> [a] -> IO ()
writePublicKeys filename xs = do
  writeFile filename $
    show $ Map.fromList $
      zip
        (zip
          (repeat localhost)
          portnums)
        xs

writePrivateKeys :: (Show name, Show a) => FilePath -> [(name,a)] -> IO ()
writePrivateKeys dirname xs = do
  mapM_ (\(fn, x) -> writeFile (dirname </> show fn ++ ".txt") (show x)) xs
