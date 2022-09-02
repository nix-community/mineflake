{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "0.2.0-beta";
in
stdenv.mkDerivation {
  inherit version;

  pname = "ElyBy";

  src = fetchurl {
    url = "https://ely.by/skinsystem-plugin/elyby-skinsystem-${version}.jar";
    sha256 = "132l414ca8x12bcnf9vx976za3c2bwaf55b33i8llydwpqx4jsis";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Skins system for your offline server";
    homepage = "https://ely.by/server-skins-system";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    deps = [ ];
    configs = { };
    server = [ "spigot" "bungee" ];
    type = "result";
    folders = [ ];
    legacy = true;
  };
}
