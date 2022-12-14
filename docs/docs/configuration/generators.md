# Configuration generators

Configuration generators are used to simplify `configs` section in `mineflake.yml` file.

For example, in `spigot` type, you can use `permissions` generator to generate LuckPerms group permissions declaratively.

``` yaml linenums="1" title="mineflake.yml" hl_lines="13-29"
type: spigot

command: "java -Xms1G -Xmx1G -jar {} nogui"

package:
  type: local
  path: /path/to/paper

plugins:
  - type: local
    path: /path/to/luckperms

permissions:
  - name: "admin"
    permissions:
      - "*"
  - name: "moderator"
    permissions:
      - "minecraft.command.ban"
      - "minecraft.command.banlist"
      - "minecraft.command.kick"
      - "minecraft.command.pardon"
  - name: "default"
    permissions:
      - "minecraft.command.help"
      - "minecraft.command.me"
      - "minecraft.command.msg"
      - "minecraft.command.tell"
      - "minecraft.command.tellraw"
```

In this example, `permissions` generator will generate LuckPerms group permissions and put them in `plugins/LuckPerms/json-storage/groups/${name}.json` files.

![Screenshot of LuckPerms web editor](https://w3s.link/ipfs/bafkreifazm27rtwncgg45dsesnjqlgoy63bp7okgabjp5tpfysxrqm6hmy)
