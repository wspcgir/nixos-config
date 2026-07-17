{...}: {
  flake.homeModules.nushell = {pkgs,...}: {
    programs.nushell = {
      enable = true;
      extraConfig = builtins.readFile ./nushell/_config.nu;
    };
  };
}