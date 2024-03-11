{ pkgs ? import <nixpkgs> { } }:

let
  # We don't want to make new dependencies in flakes, so we use the
  # fetchers from nixpkgs.
  rust-overlay = import (pkgs.fetchFromGitHub {
    owner = "oxalica";
    repo = "rust-overlay";
    rev = "cbdf3e5bb205ff2ca165fe661fbd6d885cbd0106";
    sha256 = "sha256-76PGANC2ADf0h7fe0w2nWpfdGN+bemFs2rvW2EdU/ZY=";
  });
  pkgs' = pkgs.extend rust-overlay;
in
pkgs'.mkShell {
  nativeBuildInputs = with pkgs'; [ rust-bin.stable.latest.default nixpkgs-fmt ];
}
