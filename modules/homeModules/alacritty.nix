{ ... }: {

  flake.homeModules.alacritty = { ... }: {
    programs.alacritty = {
      enable = true;
      settings = {
        font.normal = {
          family = "Dejavu Sans Mono";
          style = "Regular";
        };
        terminal.shell = {
          program = "zsh";
        };
      };
    };
  };
}
