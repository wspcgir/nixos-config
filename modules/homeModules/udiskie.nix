{ ... }: {

  flake.homeModules.udiskie = { pkgs, ... }: {
    services.udiskie = {
      enable = true;
      automount = true;
    };
  };
}
