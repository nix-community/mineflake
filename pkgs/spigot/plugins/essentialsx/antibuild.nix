{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "2.19.8";
  commit = "0897ef7";
  buildNum = "1423";
  pname = "EssentialsXAntiBuild";
in
stdenv.mkDerivation {
  inherit version pname;

  src = fetchurl {
    url = "https://ci.ender.zone/job/EssentialsX/${buildNum}/artifact/jars/${pname}-${version}-dev+1-${commit}.jar";
    hash = "sha256-SQku8XGr7ZtTyTGKSnhFzgiaW2uM7mmoL4WkCtjGgm0=";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "EssentialsX addon.";
    homepage = "https://essentialsx.net/";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    deps = [ (callPackage ./default.nix { }) ];
    configs = { };
    server = "spigot";
    type = "result";
    folders = [ ];
  };
}
