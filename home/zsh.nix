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
    shellAliases = {
      sv = "sudo vi";
      v = "vi";
      g = "git status";
      ga = "git add";
      gc = "git commit";
      sgc = "sudo git commit";
      gaa = "git add -A";
      sga = "sudo git add";
      sgaa = "sudo git add -A";
      nrs = "sudo nixos-rebuild switch";
    };
    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git-prompt" "git" "sudo" ];
    };
  };
}
