{ ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../../modules/common.nix
    ../../modules/ssh.nix
    ../../modules/tailscale.nix
    ../../modules/always-on.nix
    ../../modules/users.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Set the name of the host
  networking.hostName = "nuc-0";

  # zfs setup
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "e0b68783";
  boot.zfs.extraPools = [ "backup" ];
  services.zfs.autoScrub.enable = true;

  # Before changing this value read the documentation for this option
  system.stateVersion = "25.11"; # Did you read the comment?
}
