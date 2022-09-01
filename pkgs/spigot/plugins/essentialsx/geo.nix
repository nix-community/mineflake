{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "2.19.8";
  commit = "0897ef7";
  buildNum = "1423";
  pname = "EssentialsXGeoIP";
in
stdenv.mkDerivation {
  inherit version pname;

  src = fetchurl {
    url = "https://ci.ender.zone/job/EssentialsX/${buildNum}/artifact/jars/${pname}-${version}-dev+1-${commit}.jar";
    hash = "sha256-lwJa8GlPq+DKH9jDTRWvKeg2UTLQF+XBXjDsooYj1Qg=";
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
    configs = {
      "plugins/EssentialsGeoIP/config.yml" = {
        type = "yaml";
        data = importJSON ./geo.json;
      };
    };
    server = ["spigot"];
    type = "result";
    folders = [ "plugins/EssentialsGeoIP" ];
  };
}
