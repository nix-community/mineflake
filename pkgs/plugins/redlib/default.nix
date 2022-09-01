{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "6.5.4.1";
in
stdenv.mkDerivation {
  inherit version;

  pname = "RedLib";

  src = fetchurl {
    url = "https://github.com/Redempt/RedLib/releases/download/${version}/RedLib.jar";
    hash = "sha256-+j6D+sChbbKiwg5tF0ldcuXQyYBx79hNvLEZdUcvt9U=";
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
