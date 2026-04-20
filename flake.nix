{
  description = "Homelab NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      mkHost =
        hostname: modules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./modules/common.nix
            ./modules/tailscale.nix
            ./modules/ssh.nix
            {
              networking.hostName = hostname;
            }
          ]
          ++ modules;
        };
    in
    {
      nixosConfigurations = {
        nuc-0 = mkHost "nuc-0" [
          ./hosts/nuc-0/configuration.nix
          ./hosts/nuc-0/hardware-configuration.nix
        ];

        laptop-0 = mkHost "laptop-0" [
          ./hosts/laptop-0/configuration.nix
          ./hosts/laptop-0/hardware-configuration.nix
        ];
      };
    };
}
