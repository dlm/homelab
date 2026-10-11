{
  description = "Homelab NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    sops-nix.url = "github:Mic92/sops-nix";
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
