{ lib, ... }:
{
  options.homelab.tailscale.tailnetDomain = lib.mkOption {
    type = lib.types.str;
    default = "warg-woodpecker.ts.net";
    description = "This tailnet's MagicDNS domain suffix.";
  };

  config.services.tailscale.enable = true;
}
