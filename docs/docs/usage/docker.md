# Docker

You can build Docker images with Mineflake.

## With Nix

First, you need to add mineflake to your `flake.nix`. You can read more [here](nixos.md).

You can simply use `buildMineflakeContainer` function:

``` nix linenums="1" title="docker.nix"
{ mineflake, ... }:

mineflake.buildMineflakeContainer {
    type = "spigot";
    command = "java -Xms1G -Xmx1G -jar {} nogui";
    package = mineflake.paper;
}
```

Or if you want better layer caching, you can use `buildMineflakeLayeredContainer` function:

``` nix linenums="1" title="docker.nix"
{ mineflake, ... }:

mineflake.buildMineflakeLayeredContainer {
    type = "spigot";
    command = "java -Xms1G -Xmx1G -jar {} nogui";
    package = mineflake.paper;
}
```

Build derivation, then import it to Docker:

``` bash
nix build .#docker
docker load < result
```

Then you can run it:

``` bash
docker run -it --rm -p 25565:25565 -v $(pwd)/server:/data mineflake
```

## With Dockerfile

You can also use `Dockerfile` to build Mineflake images:

``` dockerfile linenums="1" title="Dockerfile"
FROM rust:slim-buster as builder

RUN cargo install mineflake


FROM debian:buster-slim as final

ENV MINEFLAKE_CACHE=/cache
RUN mkdir -p $MINEFLAKE_CACHE

COPY --from=builder /usr/local/cargo/bin/mineflake /usr/local/bin/mineflake
COPY mineflake.yml /mineflake.yml

WORKDIR /data

# This will download all dependencies and cache them in Docker layer.
# So image can be run offline.
RUN mineflake vendor

CMD mineflake apply -r -c /mineflake.yml
```

???+ warning "Local packages in Dockerfile"

    Local packages are supported only if you `COPY` them to image at same path as in `mineflake.yml`.

??? warning "Java is not included"

    If you need Java to run your server, you need to install it yourself. You can use `openjdk:slim-buster` image as base instead of `debian:buster-slim`.

This Dockerfile will build Mineflake image with `mineflake.yml` configuration and it dependencies.

Build it:

``` bash
docker build -t mineflake .
```

Then you can run it:

``` bash
docker run -it --rm -p 25565:25565 -v $(pwd)/server:/data mineflake
```
