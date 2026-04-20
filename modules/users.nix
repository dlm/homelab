{ ... }:
{
  users.users.dave = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH+DG0xr1r6Z/lfhI97nUZvUDhQTiSbxaCyRP7GKfJ52 dave@zbornak"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJeNhaORfgxVdjqqEX2/rR/4z6viQYVFrGidXx4N9F4V dave@petrillo"
    ];
  };
}
