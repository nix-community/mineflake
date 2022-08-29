{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation {
  pname = "IllegalStack";
  version = "2.6";

  src = fetchurl {
    url = "https://w3s.link/ipfs/bafybeifkdmibkf2ho5n6iaxkglbzffpbti75qtfzhilo7466vgjmkji2ta/IllegalStack-2.6.jar";
    sha256 = "10lmxgbi8dj75ya05swvgiykaj6zssz46z0r155hfqhg4nyw9xji";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "A spigot based plugin dedicated to fixing glitches and exploits that have made it into final Minecraft releases";
    homepage = "https://github.com/dniym/IllegalStack";
    license = licenses.gpl3;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/IllegalStack/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
      "plugins/IllegalStack/messages.yml" = {
        type = "yaml";
        data = importJSON ./messages.yml.json;
      };
    };
    server = "spigot";
    type = "result";
    folders = [ "plugins/IllegalStack" ];
  };
}
