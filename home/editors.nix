{ inputs, pkgs, ... }: 

{
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;
    defaultEditor = true;
    settings = {
      vim = {
        theme = {
          enable = true;
          name = "gruvbox";
          style = "dark";
        };
        viAlias = true;
        vimAlias = true;
        lsp.enable = true; 
        statusline.lualine.enable = true;
        telescope.enable = true;
        autocomplete.nvim-cmp.enable = true;
        languages = {
          enableTreesitter = true;
          nix.enable = true;
          rust.enable = true;
        };

        options = {
          tabstop = 2;
          smartindent = true;
          shiftwidth = 2;
        };
      };
    };
  };

  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        userSettings = {
          "nix.suggest.paths" = false;
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nil";
          "nix.serverSettings" = {
            nil = { formatting = { command = [ "nixfmt" ]; }; };
          };
        };
        extensions = with pkgs.vscode-extensions; [
          vscodevim.vim
          jnoortheen.nix-ide
          haskell.haskell
          mkhl.direnv
          rust-lang.rust-analyzer
        ];
      };
    };
  };
}
