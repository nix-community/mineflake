{ lib, fetchurl, stdenv, ... }:

let
  buildNum = "1661";
  mcVersion = "1.19";
  cmd_find = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeidjszlckqq2jwykzkxrla63gg5vub2moz5tykxfxke2fiukvwnr4a/cmd_find.jar";
    sha256 = "0951l4j14d2vp1l5bn40nf3bqani89gn4fnxws2lqy7gvz04j7d2";
  };
  cmd_kick = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeie77dwt7nst4vui63tz5hmldaorrkixabtraujcle3xfp57vj5pia/cmd_kick.jar";
    sha256 = "0dxvfh451vxhifmxcllfhpgnbalpyha0cwq4jcm1npbv1x264m35";
  };
  cmd_list = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeidsdx77vr2q2jscrioqai46edlrv2gas6ebi7hm34krmgyksgl5bu/cmd_list.jar";
    sha256 = "0k0k70drc4k308ga4vp1xpgzch4bx1zafk4hpxsxvmqbaqc2fv1b";
  };
  cmd_send = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeicmprxqhdlasgdlhtolwv3f2mqku2o63tlwo4j7yogfftu7v7ff4m/cmd_send.jar";
    sha256 = "1h8m5ywp5gl7dlmwf15sqcrmwm54z5xwff1h9w0bl0zs5gx1fcgi";
  };
  cmd_alert = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeic4ixwsbg3hr2zvlrucvp7otup4jsjhzw4yhdnhsbynos2f4cbl6m/cmd_alert.jar";
    sha256 = "165k5ds4jbl71zldlk7l9y1wpxqfyy9dj443c94has17hcbx75wa";
  };
  cmd_server = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeihvextf23ppvk3qmozktle6tpnalvnge3zdeidxfpynltsnlwd2rq/cmd_server.jar";
    sha256 = "1qrqarzdq5w5bar0h53379wipa8w7sd3c0hrmfiq7gxigy9wlsah";
  };
  reconnect_yaml = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeifa4cvuoaxudteospv3ig7kvlsgp3lvvcwpjc3dytedvnjmdeuvji/reconnect_yaml.jar";
    sha256 = "0qwm6047i7mcv3kf1kgqrabvc05gykmj1p96bdk113bn6dsy4yq3";
  };
in
stdenv.mkDerivation {
  pname = "bungeecord";
  version = "${mcVersion}r${buildNum}";
  src = fetchurl {
    url = "https://static.ipfsqr.ru/ipfs/bafybeicwjr4mt4blnsihxypy4dkt3o2ufnosk5xwzdq43gcmrfmct7arqi/BungeeCord.jar";
    sha256 = "0fk3ck3qh1n2m943g0nsmhn9dnab6cipvyf6cvqfadrcay23985k";
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
