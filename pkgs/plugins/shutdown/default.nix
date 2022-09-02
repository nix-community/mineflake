{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "0.1.0";
in
stdenv.mkDerivation {
  inherit version;

  pname = "Shutdown";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeic74odzzawl4uvhdxk6tszs64u6or3e753bto5bb7pkyv55iy7b4y/shutdown.jar";
    sha256 = "1va7sfy3cxkgh280vk2amjkzhmi3siwb4anp0dazy06l9j8fxin6";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Shutdown your server";
    homepage = "https://git.frsqr.xyz/firesquare/Shutdown";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    deps = [ (callPackage ../redlib { }) (callPackage ../vault { }) ];
    configs = {
      "plugins/Shutdown/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
      "plugins/Shutdown/lang.yml" = {
        type = "yaml";
        data = importJSON ./lang.yml.json;
      };
    };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/Shutdown" ];
  };
}
