{ lib, fetchurl, stdenv, mineflake, ... }:

mineflake.buildMineflakePackage rec {
  pname = "paper";
  version = "${mcVersion}r${buildNum}";
  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeiac2fccdukavrpykqix4xgcwr6qqzm2wyxkkoov5ucxvzt3xznvxa/paper-${mcVersion}-${buildNum}.jar";
    sha256 = "0an6xbniqzw6v0zh5ygxmnq4fwaam07jbjn1razahml25ww1vy36";
  };

  mcVersion = "1.19.2";
  buildNum = "175";

  dontUnpack = true;
  dontConfigure = true;
  installPhase = ''
    mkdir -p $out
    install -Dm444 $src $out/package.jar
  '';

  meta = with lib; {
    description = "High-performance Minecraft Server";
    homepage = "https://papermc.io/";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
  };
}
