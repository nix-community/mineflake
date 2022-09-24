{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "ClansFork";
  version = "0.0.1";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/QmPQJwd1WFp1jNw8WCf67x9hxoa6oHa3WYBQ7n4EHAwvVy";
    sha256 = "0hna83fid5f0ag2i21a3gml67v9097zrrgjqjid22hizb6qlqcs5";
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
        data = importJSON ./messages.json;
      };
      "plugins/ClansFork/Settings/messages.yml" = {
        type = "yaml";
        data = importJSON ./config.json;
      };
    };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/ClansFork/Settings" ];
  };
}
