# mineflake

[![license gpl3.0](https://img.shields.io/static/v1?label=License&message=GPL%203.0&color=FE7D37)](https://git.frsqr.xyz/firesquare/mineflake/src/branch/main/LICENSE) [![gitea](https://img.shields.io/static/v1?label=Code%20on&message=Gitea&color=009C08&logo=gitea)](https://git.frsqr.xyz/firesquare/mineflake) [![wakatime](https://wakatime.com/badge/user/ebd31081-494e-4581-b228-7619d0fe1080/project/c81c6e21-8431-4002-839f-b7e8da67c3ae.svg)](https://wakatime.com/badge/user/ebd31081-494e-4581-b228-7619d0fe1080/project/c81c6e21-8431-4002-839f-b7e8da67c3ae)

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
