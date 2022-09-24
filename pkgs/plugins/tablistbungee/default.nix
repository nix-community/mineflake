{ callPackage, lib, stdenv, fetchurl, ... }:

stdenv.mkDerivation rec {
  pname = "TabListBungee";
  version = "2.3.0";

  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/QmWcbRxoayEG8ksZmnj8uBX4g3xru6VcP6iMVzqHzmrBVr";
    sha256 = "076njjz1ighhm7h67pvqidvy82xfwsax8i6952z6s1wf06lri9a3";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Animated tab";
    homepage = "https://github.com/montlikadani/TabList";
    license = licenses.mit;
    platforms = platforms.all;
    deps = [ ];
    configs = {
      "plugins/TabList/bungeeconfig.yml" = {
        type = "yaml";
        data = importJSON ./bungeeconfig.yml.json;
      };
    };
    server = [ "bungee" ];
    type = "result";
    folders = [ "plugins/" ];
  };
}
