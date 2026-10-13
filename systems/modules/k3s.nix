{
  config,
  lib,
  k3sServerHost,
  ...
}:
let
  cfg = config.homelab.k3s;
  isServer = config.networking.hostName == k3sServerHost;
  serverFqdn = "${k3sServerHost}.${config.homelab.tailscale.tailnetDomain}";
in
{
  options.homelab.k3s.enable = lib.mkEnableOption "k3s";

  config = lib.mkIf cfg.enable {
    sops.defaultSopsFile = ../secrets/k3s.yaml;
    sops.secrets.nodeToken.key = "node-token";
    services.k3s = {
      enable = true;
      tokenFile = config.sops.secrets.nodeToken.path;
      role = if isServer then "server" else "agent";
    }
    // lib.optionalAttrs (isServer) { extraFlags = "--tls-san=${serverFqdn}"; }
    // lib.optionalAttrs (!isServer) { serverAddr = "https://${serverFqdn}:6443"; };

    # open up the flannel vxlan overlay between k3s nodes
    networking.firewall.allowedUDPPorts = [ 8472 ];

    # open for k8s API server - pods on other nodes need this to reach the
    # server via the in-cluster kubernetes service;
    networking.firewall.allowedTCPPorts = lib.mkIf isServer [ 6443 ];
  };
}
