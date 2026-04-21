{ ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../../modules/common.nix
    ../../modules/ssh.nix
    ../../modules/tailscale.nix
    ../../modules/users.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Set the name of the host
  networking.hostName = "nuc-0";

  # Set the power settings
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    extraConfig = ''
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
      HandleLidSwitch=ignore
      HandleLidSwitchDocked=ignore
      IdleAction=ignore
    '';
  };

  # Before changing this value read the documentation for this option
  system.stateVersion = "25.11"; # Did you read the comment?
}
