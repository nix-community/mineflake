{ callPackage, lib, stdenv, fetchurl, ... }:

let
  version = "1.7.3";
in
stdenv.mkDerivation {
  inherit version;

  pname = "Vault";

  src = fetchurl {
    url = "https://github.com/MilkBowl/Vault/releases/download/${version}/Vault.jar";
    hash = "sha256-prXtl/Q6XPW7rwCnyM0jxa/JvQA/hJh1r4s25s930B0=";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = "install -Dm444 $src $out";

  meta = with lib; {
    description = "Abstraction Library for Bukkit";
    homepage = "https://github.com/MilkBowl/Vault";
    license = licenses.lgpl3;
    platforms = platforms.all;
    deps = [ ];
    configs = { };
    server = "spigot";
    type = "result";
    folders = [ ];
  };
}
