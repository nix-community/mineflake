{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "ProtocolLib";
  version = "4.8.0";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/QmP8bi2BQrTGDfzhVg57ZgRCJcLpvPGy61k15JeeXJyfKH";
    sha256 = "10qnrqf06y6lyabp38ya9dsnp6gh51l1m2wvcb4vp12i3f43pmwm";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Provides read and write access to the Minecraft protocol with Bukkit";
    homepage = "https://github.com/dmulloy2/ProtocolLib";
    license = licenses.gpl2;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/ProtocolLib/config.yml" = {
        type = "yaml";
        data = importJSON ./config.yml.json;
      };
    };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/ProtocolLib" ];
  };
}
