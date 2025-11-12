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
      g = "git status";
      ga = "git add";
      nrs = "sudo nixos-rebuild switch";
    };
    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git-prompt" "git" "sudo" ];
    };
  };
}
