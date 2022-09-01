{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "4.8.0";
in
stdenv.mkDerivation {
  inherit version;

  pname = "ProtocolLib";

  src = fetchurl {
    url = "https://github.com/dmulloy2/ProtocolLib/releases/download/${version}/ProtocolLib.jar";
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
