{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "TabTPS";
  version = "1.3.15";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/QmStzUwiCCNv2V7byCNGwpwf5HdJmtKVCwLQFVPvbDWUTq";
    sha256 = "1f9w6rdmma009x8k3l4k2h006swkascd8mk2mqi5bm3vj95515q8";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Minecraft server mod/plugin to show TPS, MSPT, and other information in the tab menu, boss bar, and action bar";
    homepage = "https://github.com/jpenilla/TabTPS";
    license = licenses.mit;
    platforms = platforms.all;
    deps = [ ];
    configs = { };
    server = [ "spigot" ];
    type = "result";
    folders = [ "plugins/TabTPS" ];
  };
}
