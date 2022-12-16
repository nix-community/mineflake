{ pkgs, stdenv, importCargo, rustc, cargo, openssl, pkg-config, ... }:

{
  default = stdenv.mkDerivation {
    name = "mineflake";
    src = ./.;

    nativeBuildInputs = [
      (importCargo { lockFile = ./Cargo.lock; inherit pkgs; }).cargoHome

      # Build-time dependencies
      rustc
      cargo
      openssl.dev
      pkg-config
    ];

    buildPhase = ''
      cargo build --release --offline
    '';

    installPhase = ''
      install -Dm775 ./target/release/mineflake $out/bin/mineflake
    '';
  };

  offline = stdenv.mkDerivation {
    name = "mineflake-offline";
    src = ./.;

    nativeBuildInputs = [
      (importCargo { lockFile = ./Cargo.lock; inherit pkgs; }).cargoHome

      # Build-time dependencies
      rustc
      cargo
    ];

    buildPhase = ''
      cargo build --release --no-default-features --features cli --offline
    '';

    installPhase = ''
      install -Dm775 ./target/release/mineflake $out/bin/mineflake
    '';
  };
}
