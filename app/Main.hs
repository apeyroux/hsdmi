{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# OPTIONS_GHC -fno-warn-type-defaults #-}

module Main where

import           Control.Applicative
import           Data.Attoparsec.Combinator
import           Data.Attoparsec.Text
import           Data.Char
import           Data.List
import qualified Data.Text as T
import           Shelly

data Screen = Screen {
  screenNumber :: Int
  , screenMonitors :: [Monitor] } deriving Show

data Monitor = Monitor {
  monitorName :: T.Text
  , monitorConnected :: Bool
  , monitorPrimary :: Bool } deriving Show

parseScreen :: Parser Screen
parseScreen = do
  _  <- many' letter
  number <- space *> digit
  _ <- manyTill anyChar endOfLine
  monitors <- many' $ try parseMonitor
  return $ Screen (digitToInt number) monitors

parseMonitor :: Parser Monitor
parseMonitor = do
  name <- many' letter
  id <- digit
  _ <- space
  connected <- (== "connected") <$> many' letter
  _ <- space
  primary <- (== "primary") <$> many' letter
  _ <- manyTill' anyChar endOfLine *> try (many' $ space *> manyTill' anyChar endOfLine)
  return $ Monitor (T.pack $ name <> [id]) connected primary

main :: IO ()
main = shelly $ silently $ do
  x <- xrandr ["-q"]
  case parseOnly parseScreen x of
    Right s -> 
      case Data.List.find monitorPrimary (screenMonitors s) of
        Just p -> case Data.List.find (\x -> monitorName x == "HDMI1" && monitorConnected x) (screenMonitors s) of
          Just m -> xrandr_ (T.words $ "--output " <> monitorName p <> " --off --output " <> monitorName m <> " --auto")
          Nothing -> xrandr_ (T.words $ "--output " <> monitorName p <> " --auto")
        Nothing -> echo "No primary ! :("
    Left e -> echo $ T.pack e
  where
    xrandr = run (fromText "xrandr")
    xrandr_ = run_ (fromText "xrandr")
