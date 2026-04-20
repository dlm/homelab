{ pkgs, lib, ... }:

{
  # this need a pass though to clean up so that it has the real common set

#  networking.firewall.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    git
    vim
  ];
}
