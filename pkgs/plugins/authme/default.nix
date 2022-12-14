{ callPackage, lib, stdenv, fetchurl, mineflake, ... }:

stdenv.mkDerivation rec {
  pname = "AuthMe";
  version = "5.6.0-beta2";

  src = fetchurl {
    url = mineflake.ipfsUrl "QmdwFv1FLzBWv6Z7kA186TZzgHmnpvAZJW7VSqyBGZXJRY";
    sha256 = "11i33gjnj1nq8cdnkfr24rgj30cdg3capdjr592qnaj3dqav9wxz";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = ''
    mkdir $out
    install -Dm444 ${./package.yml} $out/package.yml
    install -Dm444 $src $out/package.jar
  '';

  meta = with lib; {
    description = "Prevent username stealing on your server";
    homepage = "https://github.com/AuthMe/AuthMeReloaded";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
