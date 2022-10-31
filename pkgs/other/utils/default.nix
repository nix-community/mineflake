{ lib, rustPlatform, fetchgit, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "mineflake-cli";
  version = "0.1.0";

  src = ./cli;

  doCheck = false;

  cargoSha256 = "sha256-P1CoGmcJulkIol+oYwIxt428LCqTMzk/lFJcplolJVA=";

  nativeBuildInputs = [ pkg-config ];

  meta = with lib; {
    description = "Mineflace CLI";
    license = licenses.gpl3;
  };
}
