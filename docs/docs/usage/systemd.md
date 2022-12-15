# systemd

Systemd is a system and service manager for Linux. It is used by many Linux distributions, including NixOS.

## With NixOS

``` nix linenums="1" title="configuration.nix"
{ pkgs, ... }:

{
  systemd.services.mineflake-example-server = {
    description = "Mineflake server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      User = "minecraft-example-server";
      Group = "minecraft-example-server";
      ExecStart = pkgs.mineflake.buildMineflakeBin {
        type = "spigot";
        command = "${pkgs.jre_headless}/bin/java -Xms1G -Xmx1G -jar {} nogui";
        package = pkgs.mineflake.paper;
      };
      WorkingDirectory = "/var/lib/minecraft-example-server";
    };
  };

  users.users.minecraft-example-server = {
    isSystemUser = true;
    home = "/var/lib/minecraft-example-server";
  };

  users.groups.minecraft-example-server = {};
}
```

## With other Linux distributions

### Install Mineflake

See [installation](/).

### Create a user

``` bash
sudo useradd -r -s /bin/false -d /var/lib/minecraft-example-server minecraft-example-server
sudo mkdir /var/lib/minecraft-example-server
sudo chown minecraft-example-server:minecraft-example-server /var/lib/minecraft-example-server
```

### Create a service

``` nix linenums="1" title="/etc/systemd/system/mineflake-example-server.service"
[Unit]
Description=Mineflake server
After=network.target

[Service]
Type=simple
User=minecraft-example-server
Group=minecraft-example-server
ExecStart=/usr/local/bin/mineflake apply -r -c /etc/mineflake/example-server.yml
WorkingDirectory=/var/lib/minecraft-example-server

[Install]
WantedBy=multi-user.target
```

### Create a configuration

``` yaml linenums="1" title="/etc/mineflake/example-server.yml"
defaults:
  repo: &repo "https://raw.githubusercontent.com/nix-community/mineflake/8f442611468fc60cd07003447d6c7625e60a50e4/repo.json"

type: spigot

command: "java -Xms1G -Xmx1G -jar {} nogui"

package:
  type: local
  path: /path/to/paper

plugins:
  - type: repository
    repo: *repo
    name: luckperms

configs:
  - type: raw
    path: server.properties
    content: |
      enable-command-block=true
      enable-rcon=true
      rcon.password=123
      rcon.port=25575
```

### Start the service

``` bash
sudo systemctl start mineflake-example-server
```

Check the status:

``` bash
sudo systemctl status mineflake-example-server
```

### Enable the service

If you want the service to start automatically on boot:

``` bash
sudo systemctl enable mineflake-example-server
```
