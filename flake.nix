{
  description = "Homelab project dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          just
          git
          sops
          kubectl
        ];

        shellHook = ''
          if [ -z "$XDG_RUNTIME_DIR" ]; then
            echo "XDG_RUNTIME_DIR is not set; refusing to guess where to put the decrypted kubeconfig" >&2
            exit 1
          fi
          KUBECONFIG_PATH="$XDG_RUNTIME_DIR/homelab-kubeconfig"
          (umask 077; sops -d secrets/kube-config.yaml > "$KUBECONFIG_PATH")
          export KUBECONFIG="$KUBECONFIG_PATH"
        '';

      };
    };
}
