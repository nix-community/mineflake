{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "AuthMe";
  version = "5.6.0-beta2";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/QmdwFv1FLzBWv6Z7kA186TZzgHmnpvAZJW7VSqyBGZXJRY";
    sha256 = "11i33gjnj1nq8cdnkfr24rgj30cdg3capdjr592qnaj3dqav9wxz";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Prevent username stealing on your server";
    homepage = "https://github.com/AuthMe/AuthMeReloaded";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/AuthMe/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
    };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/AuthMe" "plugins/AuthMe/messages" ];
  };
}
