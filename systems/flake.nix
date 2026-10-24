{
  description = "Homelab NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      k3sServerHost = "laptop-0";
    in
    {
      nixosConfigurations.nuc-0 = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs k3sServerHost; };
        modules = [
          ./hosts/nuc-0/configuration.nix
          inputs.sops-nix.nixosModules.sops
        ];
      };

      nixosConfigurations.laptop-0 = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs k3sServerHost; };
        modules = [
          ./hosts/laptop-0/configuration.nix
          inputs.sops-nix.nixosModules.sops
        ];
      };
    };
}
