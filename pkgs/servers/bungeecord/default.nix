{ lib, fetchurl, stdenv, ... }:

let
  buildNum = "1661";
  mcVersion = "1.19";
  cmd_find = fetchurl {
    url = "https://ci.md-5.net/job/BungeeCord/${buildNum}/artifact/module/cmd-find/target/cmd_find.jar";
    hash = "sha256-tGs3xYxN9t2q6kO5zeWoJMqGh3V4e1ljV447PpClcKU=";
  };
  cmd_kick = fetchurl {
    url = "https://ci.md-5.net/job/BungeeCord/${buildNum}/artifact/module/cmd-kick/target/cmd_kick.jar";
    hash = "sha256-6LD0fdT/3NUVJ3UtNxnzT1vZ2d88Eor/FYgI0dt8Mog=";
  };
  cmd_list = fetchurl {
    url = "https://ci.md-5.net/job/BungeeCord/${buildNum}/artifact/module/cmd-list/target/cmd_list.jar";
    hash = "sha256-DoFo4YkjHzgTBystuJZa3ATpvILGz2EsNmQ/u5IEl44=";
  };
  cmd_send = fetchurl {
    url = "https://ci.md-5.net/job/BungeeCord/${buildNum}/artifact/module/cmd-send/target/cmd_send.jar";
    hash = "sha256-GON6gso4DX/+2qtywM1zB916KUiaZfIwupmbRx8aw/A=";
  };
  cmd_alert = fetchurl {
    url = "https://ci.md-5.net/job/BungeeCord/${buildNum}/artifact/module/cmd-alert/target/cmd_alert.jar";
    hash = "sha256-33DV20OK9nSIpRixKXdK3IA7HXElosdmyTh8mzGN84c=";
  };
  cmd_server = fetchurl {
    url = "https://ci.md-5.net/job/BungeeCord/${buildNum}/artifact/module/cmd-server/target/cmd_server.jar";
    hash = "sha256-1brlgoKr6305JxH1PRsW2SHCyuQ6blzcPtWiSVwZz7M=";
  };
  reconnect_yaml = fetchurl {
    url = "https://ci.md-5.net/job/BungeeCord/${buildNum}/artifact/module/reconnect-yaml/target/reconnect_yaml.jar";
    hash = "sha256-JjzB6QBai05/J2WZvuDcgnNHrVjri5rNALJwaBGy2tQ=";
  };
in
stdenv.mkDerivation {
  pname = "bungeecord";
  version = "${mcVersion}r${buildNum}";
  src = fetchurl {
    url = "https://ci.md-5.net/job/BungeeCord/${buildNum}/artifact/bootstrap/target/BungeeCord.jar";
    hash = "sha256-s6A0hFcsN+XwZsb5fSMzS9mWLKzagjdIqsIGiMdkYzo=";
  };

  dontUnpack = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out
    install -Dm444 $src $out/result
    mkdir -p $out/modules
    install -Dm444 ${cmd_find} $out/modules/cmd_find.jar
    install -Dm444 ${cmd_kick} $out/modules/cmd_kick.jar
    install -Dm444 ${cmd_list} $out/modules/cmd_list.jar
    install -Dm444 ${cmd_send} $out/modules/cmd_send.jar
    install -Dm444 ${cmd_alert} $out/modules/cmd_alert.jar
    install -Dm444 ${cmd_server} $out/modules/cmd_server.jar
    install -Dm444 ${reconnect_yaml} $out/modules/reconnect_yaml.jar
  '';

  meta = with lib; {
    description = "BungeeCord is a sophisticated proxy and API designed mainly to teleport players between multiple Minecraft servers";
    homepage = "https://github.com/SpigotMC/BungeeCord";
    license = licenses.mit;
    platforms = platforms.unix;
    server = "bungee";
    type = "complex";
    struct = {
      "modules/cmd_find.jar" = "modules/cmd_find.jar";
      "modules/cmd_kick.jar" = "modules/cmd_kick.jar";
      "modules/cmd_list.jar" = "modules/cmd_list.jar";
      "modules/cmd_send.jar" = "modules/cmd_send.jar";
      "modules/cmd_alert.jar" = "modules/cmd_alert.jar";
      "modules/cmd_server.jar" = "modules/cmd_server.jar";
      "modules/reconnect_yaml.jar" = "modules/reconnect_yaml.jar";
    };
    folders = [
      "plugins"
      "modules"
    ];
    configs = {
      "config.yml" = {
        type = "yaml";
        data = (importJSON ./config.yml.json);
      };
    };
  };
}
