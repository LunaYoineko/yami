# Package

version       = "0.1.0"
author        = "LunaYoineko"
description   = "Yami Bot for Nim"
license       = "MIT"
srcDir        = "src"
bin           = @["yami"]


# Dependencies

requires "nim >= 2.2.10"
requires "ws"
requires "secp256k1"
requires "nimSHA2"
requires "regex"
requires "dotenv"
requires "https://github.com/LunaYoineko/nimstr"