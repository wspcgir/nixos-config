{ config, ... }: {
  flake.homeModules.zsh =
    let
      aliases = config.common-lib.aliases;

      colorAliases = config.common-lib.map-attrs ({ name, value }: {
        name = name;
        value = "printf \"\\033]11;#${value}\\007\"";
      }) config.common-lib.colors;

      nonSudoAliases = {
        nrs = "sudo nixos-rebuild switch";
      }
      // aliases
      // colorAliases;

      sudoAliases = config.common-lib.map-attrs ({ name, value }: {
        name = "s${name}";
        value = "sudo ${value}";
      }) aliases;
    in
    { pkgs, ... }:
    {

      home.shell.enableZshIntegration = true;

      home.packages = with pkgs; [
        zsh-powerlevel10k
      ];

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        initContent = ''
          EDITOR="nvim"
        '';
        shellAliases = nonSudoAliases // sudoAliases;
        oh-my-zsh = {
          enable = true;
          theme = "agnoster";
          plugins = [
            "git-prompt"
            "git"
            "sudo"
          ];
        };
      };
    };
}
