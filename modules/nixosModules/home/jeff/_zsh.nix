{ pkgs, ... }: {

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
    shellAliases = {
      # VIM
      v = "vi";
      sv = "sudo vi";

      # GIT
      g = "git status";
      ga = "git add";
      gaa = "git add -A";
      sga = "sudo git add";
      sgaa = "sudo git add -A";
      gc = "git commit";
      sgc = "sudo git commit";
      gpl = "git pull";
      sgpl = "sudo git pull";
      gpsh = "git push";
      sgpsh = "sudo git push";
      gs = "git stash";
      sgs = "sudo git stash";

      # NIX
      nrs = "sudo nixos-rebuild switch";

    };
    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git-prompt" "git" "sudo" ];
    };
  };
}
