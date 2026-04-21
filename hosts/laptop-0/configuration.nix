{ ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../../modules/common.nix
    ../../modules/ssh.nix
    ../../modules/tailscale.nix
    ../../modules/users.nix
    ../../modules/always-on.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set the name of the host
  networking.hostName = "laptop-0";

  # Before changing this value read the documentation for this option
  system.stateVersion = "25.11"; # Did you read the comment?
}
