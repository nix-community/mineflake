{ lib, stdenv, fetchurl, ... }:

let
  version = "2.19.8";
  commit = "0897ef7";
  buildNum = "1423";
  pname = "EssentialsX";
in
stdenv.mkDerivation {
  inherit version pname;

  src = fetchurl {
    url = "https://ci.ender.zone/job/EssentialsX/${buildNum}/artifact/jars/${pname}-${version}-dev+1-${commit}.jar";
    hash = "sha256-PTCT0eIVUetAXmpwrWfNzUM8aUEIrQYx+bRdRuzTspk=";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "EssentialsX is the essential plugin suite for Minecraft servers, with over 130 commands for servers of all size and scale.";
    homepage = "https://essentialsx.net/";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/Essentials/config.yml" = {
        type = "yaml";
        data = importJSON ./config.json;
      };
    };
    server = ["spigot"];
    type = "result";
    folders = [ "plugins/Essentials" ];
  };
}
