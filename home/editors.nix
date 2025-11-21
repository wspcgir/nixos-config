{ inputs, pkgs, lib, ... }: 

{ imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = let
    mxw-prolog = {
      package = pkgs.vimUtils.buildVimPlugin {
        pname = "mxw-prolog";
        version = "1.0";
        src = pkgs.fetchFromGitHub {
          owner = "mxw";
          repo = "vim-prolog";
          rev = "093235a78012032b7d53b0e06757bf919380bf3b";
          sha256 = "sha256-+g/McJ1YpjsBjFd6/Uojyl4p9pCCxUo2zQNxlEmJsYY="; 
        };
      };
    };
    in {
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

        extraPlugins = {
          inherit mxw-prolog;
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
