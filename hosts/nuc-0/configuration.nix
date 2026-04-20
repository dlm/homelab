{ ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../../modules/common.nix
    ../../modules/ssh.nix
    ../../modules/tailscale.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Set the name of the host
  networking.hostName = "nuc-0";

  system.stateVersion = "25.11"; # Did you read the comment?
}
