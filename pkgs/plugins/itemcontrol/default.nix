{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "ItemControl";
  version = "0.1.0";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeia7pvtqfhnlxdoxv34levxmqvarqvnmpnj6zqeoni4mo6ypqh6glm/ItemControl-${version}.jar";
    sha256 = "04jswxwlfp8hr33y4q37yr58gxf3j0jczq8v9b06l7q100vr7lzc";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Control item enchantments";
    homepage = "https://git.frsqr.xyz/firesquare/ItemControl";
    license = licenses.gpl3Only;
    platforms = platforms.all;
    deps = [ ];
    configs = { };
    server = [ "spigot" ];
    type = "result";
    folders = [ ];
  };
}
