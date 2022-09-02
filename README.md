# mineflake

[![license gpl3.0](https://img.shields.io/static/v1?label=License&message=GPL%203.0&color=FE7D37)](https://git.frsqr.xyz/firesquare/mineflake/src/branch/main/LICENSE) [![ci/cd status](https://wp.frsqr.xyz/api/badges/firesquare/mineflake/status.svg)](https://wp.frsqr.xyz/firesquare/mineflake) [![read the wiki](https://img.shields.io/static/v1?label=Read%20The&message=Wiki&color=7C5D63)](https://git.frsqr.xyz/firesquare/mineflake/wiki) [![read the options](https://img.shields.io/static/v1?label=Read%20The&message=Options&color=8A2BE2)](https://mineflake.ipfsqr.ru/) [![gitea](https://img.shields.io/static/v1?label=Code%20on&message=Gitea&color=009C08&logo=gitea)](https://git.frsqr.xyz/firesquare/mineflake) [![wakatime](https://wakatime.com/badge/user/ebd31081-494e-4581-b228-7619d0fe1080/project/c81c6e21-8431-4002-839f-b7e8da67c3ae.svg)](https://wakatime.com/badge/user/ebd31081-494e-4581-b228-7619d0fe1080/project/c81c6e21-8431-4002-839f-b7e8da67c3ae)

NixOS flake для лёгкого создания майнкрафт серверов через Nix конфиги.

## Минимальный конфиг

```nix
  minecraft = {
    enable = true;
    hostAddress = "192.168.100.1";
    servers.lobby = {
      localAddress = "192.168.100.2";
    };
  };
```

## Проект находится в стадии ранней разработки
