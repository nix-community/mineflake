# Использование

После установки mineflake вы можете начать его использовать.

```nix
  minecraft = {
    enable = true;
    default.hostAddress = "192.168.100.1";
    servers.example = {
      localAddress = "192.168.100.2";
      plugins = with pkgs.mineflake; [ negativity lightchatbubbles ];
    };
  };
```

Полное описание всех возможных функций смотрите на [странице опций](https://mineflake.ipfsqr.ru/options.html).

## Настройка доступа в Интернет

Контейнеры systemd-nspawn, в отличие от docker, не настраивают брандмауэр каким-либо дополнительным способом, поэтому нам нужно настроить NAT самостоятельно.

```nix
  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-+"];
  };
```

## Переадресация портов

Для открытия порта существует специальная опция `forwardPorts`.

В примере выше мы открываем порт `5000` и порт `30000`, которые будут перенаправлены на порт `25565` внутри контейнера.

```nix
  minecraft = {
    enable = true;
    default.hostAddress = "192.168.100.1";
    servers.example = {
      localAddress = "192.168.100.2";
      forwardPorts = [ "30000:25565", 5000 ];
    };
  };
```

## Bungeecord

Mineflake полностью поддерживает функциональность bungeecord. Ниже приведена минимальная конфигурация с прокси-сервером, лобби и игровым сервером.

```nix
  minecraft = {
    enable = true;
    default.hostAddress = "192.168.100.1";
    servers = {
      proxy = {
        localAddress = "192.168.100.2";
        forwardPorts = [ 25565 ];
        bungeecord = {
          enable = true;
          online_mode = false;
          servers = {
            lobby.address = "192.168.100.3";
            main.address = "192.168.100.4";
          };
          listeners = [
            {
              host = "0.0.0.0:25565";
              motd = "Some cool server!";
              priorities = [ "lobby" ];
            }
          ];
        };
      };
      lobby = {
        localAddress = "192.168.100.3";
        properties = {
          enable = true;
          online-mode = false;
        };
      };
      main = {
        localAddress = "192.168.100.4";
        properties = {
          enable = true;
          online-mode = false;
        };
      };
    };
  };
```

## Пользовательские конфигурации

Не все плагины имеют Nix опции, написанные для них - так как это долгая и муторная ручная работа. Вместо этого вы можете использовать
более низкоуровневый способ управления конфигурациями. В примере ниже мы включаем сессии в плагине `AuthMe`.

```nix
  minecraft = {
    enable = true;
    default.hostAddress = "192.168.100.1";
    servers = {
      main = {
        localAddress = "192.168.100.2";
        plugins = [ pkgs.mineflake.authme ];
        configs = {
          "plugins/AuthMe/config.yml" = {
            type = "yaml";
            data = {
              settings.sessions.enabled = true;
            };
          };
        };
      };
    };
  };
```

## `default` опция

Чтобы избежать дублирования конфигураций между серверами, может быть задан параметр по умолчанию - он будет объединен со всеми серверами,
если не указано иное. Мы уже использовали это значение, когда задавали параметр `hostAddress`.

В примере ниже мы изменим файл `language.yml` `CoreProtect` для всех серверов.

```nix
  minecraft = {
    enable = true;
    default = {
      hostAddress = "192.168.100.1";
      configs = {
        "plugins/CoreProtect/language.yml" = {
          type = "yaml";
          data = {
            TELEPORTED = "We changed config value in all servers! Teleported to {0}.";
          };
        };
      };
    };
    servers = {
      example1 = {
        localAddress = "192.168.100.2";
        plugins = [ pkgs.mineflake.coreprotect ];
      };
      example2 = {
        localAddress = "192.168.100.3";
        plugins = [ pkgs.mineflake.coreprotect ];
      };
      example3 = {
        useDefault = false; # On this server, we disabled the "default" merge, so the config will not be changed here, and the hostAddress option needs to be repeated.
        hostAddress = "192.168.100.1";
        localAddress = "192.168.100.4";
        plugins = [ pkgs.mineflake.coreprotect ];
      };
    };
  };
```
