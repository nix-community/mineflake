{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "0.1.0";
in
stdenv.mkDerivation {
  inherit version;

  pname = "BlockRename";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeiezkl5itvhmgn7v7yzawlowfuswmylswc4ufpueiefdr7bdl7mcwq/BlockRename-${version}.jar";
    sha256 = "1mbzclp97d2scb3dadf351qmpqd2ahlvc4yjnvz9241amdqk17j3";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Block anvil renames";
    homepage = "https://git.frsqr.xyz/firesquare/BlockRename";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    deps = [ (callPackage ../vault { }) ];
    configs = {
      "plugins/BlockRename/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
    };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/BlockRename" ];
  };
}
