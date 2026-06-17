{
  description = "gleam version of my personal stuff management app";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    packages = with pkgs; [
      gleam
      erlang
      beamPackages.rebar3
      watchexec
    ];
  in {
    # TODO: make system independant I guess...
    devShells = {
      ${system}.default = pkgs.mkShell {
        inherit packages;
      };
    };
    apps.${system}.default = {
      type = "app";
      inherit packages;
      program = let
        dev = pkgs.writeShellApplication {
          name = "dev";
          runtimeInputs = packages;
          text = ''
            watchexec -e gleam -- gleam run
          '';
        };
      in "${dev}/bin/dev";
    };
  };
}
