{ pkgs, lib, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # allow signed packages from my workstations
  nix.settings.trusted-public-keys = [
    "petrillo-1:gMx5QyIPG0o2pLP+W1JTTe5w2UwDYHPmwQie28Yx+tg="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];

  # Install system packages
  environment.systemPackages = with pkgs; [
    git
    vim
    restic
  ];
}
