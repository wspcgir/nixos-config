{ ... }: {
  flake.homeModules."jeff/zsh" = { pkgs, ... }: let 
    nonSudoAliases = {
      nrs = "sudo nixos-rebuild switch";
    };
    mkSudo = { name, value }: { 
      name = "s${name}";
      value = "sudo ${value}";
    };
    sudoAliases = builtins.listToAttrs <| builtins.map mkSudo <| pkgs.lib.attrsToList {
      v = "vi";
      g = "git status";
      ga = "git add";
      gaa = "git add -A";
      gc = "git commit";
      gpl = "git pull";
      gpsh = "git push";
      gs = "git stash";
    };
  in {

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
        plugins = [ "git-prompt" "git" "sudo" ];
      };
    };
  };
}
