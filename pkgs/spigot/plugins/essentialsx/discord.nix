{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "2.19.8";
  commit = "0897ef7";
  buildNum = "1423";
  pname = "EssentialsXDiscord";
in
stdenv.mkDerivation {
  inherit version pname;

  src = fetchurl {
    url = "https://ci.ender.zone/job/EssentialsX/${buildNum}/artifact/jars/${pname}-${version}-dev+1-${commit}.jar";
    hash = "sha256-JXrn5muRAFDVLngGc0/g+QNgWNZz5kDv6FXdQuJ65VU=";
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
      "plugins/EssentialsDiscord/config.yml" = {
        type = "yaml";
        data = importJSON ./discord.json;
      };
    };
    server = "spigot";
    type = "result";
    folders = [ "plugins/EssentialsDiscord" ];
  };
}
