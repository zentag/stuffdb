{
  description = "gleam version of my personal stuff management app";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.defualt = pkgs.mkShell {
      packages = with pkgs; [
        gleam
      ];
    };
  };
}
