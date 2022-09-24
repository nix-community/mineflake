{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "Negativity";
  version = "1.12.2";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/Qmady3pPskcqvAUsyZcvdBWYTsC9sxFaqHTWuEdE9KDPbA";
    sha256 = "1clylby5mb53qq9wvx09yfs7zj65daf70r6n4f8lshc5wvh3qhqv";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "A Minecraft AntiCheat for Spigot";
    homepage = "https://github.com/Elikill58/Negativity";
    # TODO: fill license
    license = licenses.mit;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/Negativity/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
    };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/Negativity" ];
  };
}
