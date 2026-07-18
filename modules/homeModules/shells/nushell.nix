{ config, ... }: {
  flake.homeModules.nushell = {pkgs,...}: {
    programs.nushell = {
      enable = true;
      extraConfig = builtins.readFile ./nushell/_config.nu;
      shellAliases = config.common-lib.aliases;
    };
    programs.carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
    programs.starship = {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };
  };
}