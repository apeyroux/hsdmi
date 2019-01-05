{ mkDerivation, attoparsec, base, hpack, shelly, stdenv, text }:
mkDerivation {
  pname = "hsdmi";
  version = "0.1";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [ attoparsec base shelly text ];
  preConfigure = "hpack";
  homepage = "https://github.com/https://github.com/apeyroux/hsdmi#readme";
  license = "unknown";
  hydraPlatforms = stdenv.lib.platforms.none;
}
