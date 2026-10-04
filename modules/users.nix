{ ... }:
{
  users.users.dave = {
    isNormalUser = true;
    description = "David Millman";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLdx+x2TuJeHgGKc5SPiXlsIvlFcnzikcwaFCNOkLuu dave@zbornak"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJeNhaORfgxVdjqqEX2/rR/4z6viQYVFrGidXx4N9F4V dave@petrillo"

      # keys for restic backup tasks
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA/MAgJl3jj9/ByA+mSYQ8MmWuPLM/fOsL7QRzEgM5bu restic@petrillo"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDtBjmLug3HIIIIwZvs234JFzn9nJTSAmSVi/B9ECwF4 restic@zbornak"
    ];
  };
}
