{ ... }:
{
  imports = [
    ../../modules/common.nix
    ../../modules/ssh.nix
    ../../modules/tailscale.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "nuc";
}
