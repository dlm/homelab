{ config, lib, ... }:
let
  cfg = config.homelab.k3s;
in
{
  options.homelab.k3s = {
    enable = lib.mkEnableOption "k3s";
    role = lib.mkOption {
      type = lib.types.enum [
        "server"
        "agent"
      ];
    };
    serverAddr = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    sops.defaultSopsFile = ../secrets/k3s.yaml;
    sops.secrets.nodeToken = {
      key = "node-token";
    };

    services.k3s = {
      enable = true;
      inherit (cfg) role serverAddr;
      tokenFile = config.sops.secrets.nodeToken.path;
    };

    # any firewall rules / assertions shared by both roles go here, once
  };
}
