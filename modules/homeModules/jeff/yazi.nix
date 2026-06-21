{ ... }: {

  flake.homeModules."jeff/yazi" = { pkgs, ... }: {

    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      plugins = {
        rsync = pkgs.yaziPlugins.rsync;
        mount = pkgs.yaziPlugins.mount;
      };
    };

    services.udiskie = {
      enable = true;
      automount = true;
    };
  };
}
