{ ... }: {
  flake.homeModules."jeff/vscode" = { pkgs, ... }: let 

    # This patch is required to fix a bug with the continue
    # extension: https://github.com/continuedev/continue/issues/821
    patchedCodium = let 
      gccLibPath = pkgs.lib.makeLibraryPath [ pkgs.gcc.cc.lib ];
    in pkgs.vscodium.overrideAttrs (oldAttrs: {
      preFixup = (oldAttrs.preFixup or "") + "gappsWrapperArgs+=( --prefix LD_LIBRARY_PATH : ${gccLibPath} )";
    });

  in {

    programs.vscode = let 
      nixpkgs-extensions = with pkgs.vscode-extensions; [
        # Editing
        vscodevim.vim

        # Language Support
        haskell.haskell
        rust-lang.rust-analyzer
        mkhl.direnv
        jnoortheen.nix-ide

        # Open Source LLM Model Chats
        continue.continue
      ];
  
      marketplace-extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "vsc-prolog";
          publisher = "arthurwang";
          version = "0.8.23";
          sha256 = "sha256-Da2dCpruVqzP3g1hH0+TyvvEa1wEwGXgvcmIq9B/2cQ=";
        }
      ];

      allExtensions = nixpkgs-extensions ++ marketplace-extensions;
   
      allowedExtensions = builtins.listToAttrs 
        <| builtins.map (x: { name = x.vscodeExtUniqueId or x.name; value = true; }) 
        <| allExtensions;

    in {
      enable = true;

      package = patchedCodium;

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
            "extensions.allowed" = allowedExtensions;
            "update.mode" = "none";
          };
          extensions = allExtensions;
        };
      };
    };

    home.file.".continue/config.yaml".text = ''
      name: "Nix Local Config"
      version: "1.0.0"
      schema: "v1"
  
      models:
        - name: "qwen3"
          title: "Qwen 3"
          provider: "ollama"
          model: "qwen3:8b"
          apiBase: "http://localhost:11434"
          roles: ["chat", "edit", "apply"]
  
  
      slashCommands:
        - name: "edit"
          description: "Edit selected code"
        - name: "comment"
          description: "Add comments to code"
        - name: "cmd"
          description: "Generate shell command"
  
      # This prevents Continue from appending or searching for other models
      allowAnonymousTelemetry: false
  
      # Map the specific roles to your models
      ui:
        codeBlockRenderMode: "preview"
    '';

    home.file.".continue/config.json".text = ""; # Avoid adding a value here, you might end up with a double json object bug.
  };
}
