{
  description = "Homelab NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs, ... }:
    {
      nixosConfigurations.nuc-0 = nixpkgs.lib.nixosSystem {
          ./hosts/nuc-0/configuration.nix
        ];
      };
    };
}
