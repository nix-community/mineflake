{ pkgs ? import <nixpkgs> { } }:

rec {
  docs = with import ./docs { inherit pkgs; }; {
    html = manual.html;
  };
}
