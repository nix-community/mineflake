{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "ClansFork";
  version = "0.0.1";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeibti4nrxvnzrvlzdi62uw2qkfbyuhkgxbfllosscazkfimeqaoobi/ClansFork-0.0.1.jar";
    sha256 = "0vazgs0f583c4r6zvchl7ayal1caw2i42m1b6mgv9ckixcfv09h8";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Clans";
    homepage = "https://git.frsqr.xyz/firesquare/ClansFork";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    deps = [ (callPackage ../placeholderapi { }) ];
    configs = {
      "plugins/ClansFork/Settings/config.yml" = {
        type = "yaml";
        data = importJSON ./config.json;
      };
      "plugins/ClansFork/Settings/messages.yml" = {
        type = "yaml";
        data = importJSON ./messages.json;
      };
    };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/ClansFork/Settings" ];
  };
}
