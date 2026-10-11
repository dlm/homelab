{ config, lib, ... }:
let
  cfg = config.homelab.k3s;
in
{
  options.homelab.k3s = {
    enable = lib.mkEnableOption "k3s";
    agent = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.submodule {
          options.serverAddr = lib.mkOption {
            type = lib.types.str;
            description = "Address of the k3s server to join.";
          };
        }
      );
      default = null;
      description = "Set to join an existing server as an agent and leave as null to run as a server.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.defaultSopsFile = ../secrets/k3s.yaml;
    sops.secrets.nodeToken = {
      key = "node-token";
    };

    services.k3s = {
      enable = true;
      tokenFile = config.sops.secrets.nodeToken.path;
      role = if cfg.agent == null then "server" else "agent";
    }
    // lib.optionalAttrs (cfg.agent != null) {
      serverAddr = cfg.agent.serverAddr;
    };
  };
}
