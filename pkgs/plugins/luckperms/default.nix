{ lib, stdenv, fetchurl, mineflake, unzip, ... }:

mineflake.buildMineflakePackage rec {
  pname = "LuckPerms";
  version = "5.4";

  src = fetchurl {
    url = "https://w3s.link/ipfs/bafybeifiacv2n45dcfgwkr2rkvksy4pskyv3ajxocuhq72vb3a2d7hpz2e/luckperms.zip";
    sha256 = "18d3xqm40rh4wacaxm71fwxk2g476qnhc5andrfxqhyqvikpq22s";
  };

  dontConfigure = true;

  installPhase = ''
    mkdir -p $out
    ${unzip}/bin/unzip $src -d $out
  '';

  meta = with lib; {
    description = "A permissions plugin for Minecraft servers";
    longDescription = ''
      LuckPerms is a permissions plugin for Minecraft servers. It allows server admins to control what features
      players can use by creating groups and assigning permissions.

      It is:
        fast - written with performance and scalability in mind.
        reliable - trusted by thousands of server admins, and the largest of server networks.
        easy to use - setup permissions using commands, directly in config files, or using the web editor.
        flexible - supports a variety of data storage options, and works on lots of different server types.
        extensive - a plethora of customization options and settings which can be changed to suit your server.
        free - available for download and usage at no cost, and permissively licensed so it can remain free forever.
    '';
    homepage = "https://luckperms.net/";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
