{ config, ... }: {
  flake.homeModules.zsh =
    let
      aliases = {
        v = "vi";
        g = "git status";
        ga = "git add";
        gaa = "git add -A";
        gc = "git commit";
        gpl = "git pull";
        gpsh = "git push";
        gs = "git stash";
      };

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
