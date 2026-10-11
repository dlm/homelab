{
  description = "Homelab NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    sops-nix = {
      # Currently, we are on the last commit that works with go 1.25.
      # To move to a more recent version, we will need to update
      # to some later nixos version (not sure of the actual version).
      url = "github:Mic92/sops-nix/13616fff713a9f94055c66f15687ebdc17a335df";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosConfigurations.nuc-0 = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nuc-0/configuration.nix
          inputs.sops-nix.nixosModules.sops
        ];
      };

      nixosConfigurations.laptop-0 = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/laptop-0/configuration.nix
          inputs.sops-nix.nixosModules.sops
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          just
          git
        ];
      };
    };
}
