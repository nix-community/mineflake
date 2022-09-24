{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "RedLib";
  version = "6.5.4.1";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/QmaWsxd4sqB6PjshiWRfAWTKYEYXEd9iNUjtuaUHpPCqdA";
    sha256 = "1mdp5x3pa6dipi6xivvih34x1rbjbm4ifv8fqaib4vd1q3x86gps";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "A powerful library for Spigot plugin development with a wide range of tools to make your life easier ";
    homepage = "https://github.com/Redempt/RedLib";
    license = licenses.mit;
    platforms = platforms.all;
    deps = [ ];
    configs = { };
    server = [ "spigot" ];
    type = "result";
    folders = [ ];
  };
}
