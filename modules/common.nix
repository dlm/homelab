{ pkgs, lib, ... }:

{
  # this need a pass though to clean up so that it has the real common set
  time.timeZone = "America/Denver";

  networking.useNetworkd = lib.mkDefault true;
  networking.firewall.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  system.stateVersion = "25.05";
}
