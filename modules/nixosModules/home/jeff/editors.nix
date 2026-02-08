{ inputs, ... }: {
  flake.homeModules."jeff/editors" = { pkgs, lib, ... }: { 

    imports = [ inputs.nvf.homeManagerModules.default ];
  
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
      # Helps correct file path issues with 
      # extensions wanting something more like 
      # debian
      package = pkgs.vscode.overrideAttrs (old: {
        buildInputs = old.buildInputs or [] ++ [ pkgs.makeWrapper ];
        postIntall = old.postInstall or [] ++ [ ''
          wrapProgram $out/bin/code --add-flags '--force-disable-user-env'
        ''];
      });

      profiles = {
        default = {
          userSettings = {
            "nix.suggest.paths" = false;
            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "nil";
            "nix.serverSettings" = {
              nil = { formatting = { command = [ "nixfmt" ]; }; };
            };
            "prolog.executablePath" = "swipl";
          };
          extensions = let
            # Overrides the extension dependencies to include direnv 
            # this prevents issues with extensions not finding binaries 
            # on the path before direnv has a chance to load
            loadAfter = deps: pkg: pkg.overrideAttrs (old: {
              nativeBuildInputs = old.nativeBuildInputs or [] ++ [ pkgs.jq pkgs.moreutils ];
              preInstall = old.preInstall or "" + ''
                jq '.extensionDependencies |= . + $deps' \
                  --argjson deps ${lib.escapeShellArg (builtins.toJSON deps)} \
                  package.json | sponge package.json
              '';
            });
  
            nixpkgs-extensions = with pkgs.vscode-extensions; [
              vscodevim.vim
              jnoortheen.nix-ide
              haskell.haskell
              rust-lang.rust-analyzer
            ];
  
            marketplace-extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
              {
                name = "vsc-prolog";
                publisher = "arthurwang";
                version = "0.8.23";
                sha256 = "sha256-Da2dCpruVqzP3g1hH0+TyvvEa1wEwGXgvcmIq9B/2cQ=";
              }
            ];
  
          in [ pkgs.vscode-extensions.mkhl.direnv ] ++ map (loadAfter [ "mkhl.direnv"]) (nixpkgs-extensions ++ marketplace-extensions);
        };
      };
    };
  };
}
