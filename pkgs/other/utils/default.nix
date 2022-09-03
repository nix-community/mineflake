{ lib, rustPlatform, fetchgit, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "mineflake-cli";
  version = "0.1.0";

  src = fetchgit {
    url = "https://git.frsqr.xyz/firesquare/mineflake-cli.git";
    rev = "refs/tags/v0.1.0";
    hash = "sha256-4uRzueV+vQH9mZ6gE34YkDeBphB+4pkJHr/NPRHhCUE=";
  };

  doCheck = false;

  cargoSha256 = "sha256-P1CoGmcJulkIol+oYwIxt428LCqTMzk/lFJcplolJVA=";

  nativeBuildInputs = [ pkg-config ];

  meta = with lib; {
    description = "Mineflace CLI";
    homepage = "https://git.frsqr.xyz/firesquare/mineflake-cli";
    license = licenses.gpl3;
  };
}
