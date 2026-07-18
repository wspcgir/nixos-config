module@{ ... }: {
  flake.homeModules.vscodeCustom =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.vscodium.custom;

      # 1. Conditionally patch VSCodium only if the continue extension or custom package is enabled
      patchedCodium =
        let
          gccLibPath = lib.makeLibraryPath [ pkgs.gcc.cc.lib ];
        in
        pkgs.vscodium.overrideAttrs (oldAttrs: {
          preFixup =
            (oldAttrs.preFixup or "") + "gappsWrapperArgs+=( --prefix LD_LIBRARY_PATH : ${gccLibPath} )";
        });
    in
    {

      # --- Define Reusable Options ---
      options.programs.vscodium.custom = {
        enable = lib.mkEnableOption "Jeff's customized VSCodium configuration";

        languages = {
          nix.enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable Nix language support (nil, nixfmt, and extensions).";
          };
          rust.enable = lib.mkEnableOption "Rust language support via rust-analyzer";
          haskell.enable = lib.mkEnableOption "Haskell language support";
          prolog.enable = lib.mkEnableOption "Prolog language support (SWI-Prolog)";
          nushell.enable = lib.mkEnableOption "Nushell language support";
        };

        continue = {
          enable = lib.mkEnableOption "Continue.dev open-source AI assistant integration";
          ollamaEndpoint = lib.mkOption {
            type = lib.types.str;
            default = "http://localhost:11434";
            description = "API base URL for the local Ollama instance.";
          };
          model = lib.mkOption {
            type = lib.types.str;
            default = "qwen3:8b";
            description = "The target model for local chats.";
          };
        };
      };

      # --- Configuration Implementation ---
      config = lib.mkIf cfg.enable {

        programs.vscodium =
          let
            # Gather nixpkgs extensions conditionally based on options
            nixpkgs-extensions = [
              pkgs.vscode-extensions.vscodevim.vim
              pkgs.vscode-extensions.mkhl.direnv
            ]
            ++ lib.optional cfg.languages.nix.enable pkgs.vscode-extensions.jnoortheen.nix-ide
            ++ lib.optional cfg.languages.rust.enable pkgs.vscode-extensions.rust-lang.rust-analyzer
            ++ lib.optional cfg.languages.haskell.enable pkgs.vscode-extensions.haskell.haskell
            ++ lib.optional cfg.continue.enable pkgs.vscode-extensions.continue.continue
            ++ lib.optional cfg.languages.nushell.enable pkgs.vscode-extensions.thenuprojectcontributors.vscode-nushell-lang;

            # Gather marketplace extensions conditionally
            marketplace-extensions = lib.optionals cfg.languages.prolog.enable [
              {
                name = "vsc-prolog";
                publisher = "arthurwang";
                version = "0.8.23";
                sha256 = "sha256-Da2dCpruVqzP3g1hH0+TyvvEa1wEwGXgvcmIq9B/2cQ=";
              }
            ];

            allExtensions =
              nixpkgs-extensions ++ (pkgs.vscode-utils.extensionsFromVscodeMarketplace marketplace-extensions);

            allowedExtensions = builtins.listToAttrs (
              builtins.map (x: {
                name = x.vscodeExtUniqueId or x.name;
                value = true;
              }) allExtensions
            );

            mkProfile = settings: {

              extensions = allExtensions;

              userSettings = lib.mkMerge [
                # Base Settings
                {
                  "extensions.allowed" = allowedExtensions;
                  "update.mode" = "none";
                }
                # Conditional Nix Settings
                (lib.mkIf cfg.languages.nix.enable {
                  "nix.suggest.paths" = false;
                  "nix.enableLanguageServer" = true;
                  "nix.serverPath" = "nil";
                  "nix.serverSettings" = {
                    nil = {
                      formatting = {
                        command = [ "nixfmt" ];
                      };
                    };
                  };
                })
                # Conditional Prolog Settings
                (lib.mkIf cfg.languages.prolog.enable {
                  "prolog.executablePath" = "swipl";
                })
                settings
              ];
            };

          in
          {
            enable = true;

            # Use the patched version if continue is active, otherwise stick to standard
            package = if cfg.continue.enable then patchedCodium else pkgs.vscodium;

            profiles = module.config.common-lib.map-attrs 
              ({name, value}: {
                name = name;
                value = mkProfile { 
                  "workbench.colorCustomizations" = { 
                    "titleBar.activeBackground" = "#${value}"; 
                  }; 
                };
              })
              module.config.common-lib.colors;
          };

        # --- Conditional Continue Configuration Files ---
        home.file = lib.mkIf cfg.continue.enable {
          ".continue/config.yaml".text = ''
            name: "Nix Local Config"
            version: "1.0.0"
            schema: "v1"

            models:
              - name: "${cfg.continue.model}"
                title: "Local LLM"
                provider: "ollama"
                model: "${cfg.continue.model}"
                apiBase: "${cfg.continue.ollamaEndpoint}"
                roles: ["chat", "edit", "apply"]

            slashCommands:
              - name: "edit"
                description: "Edit selected code"
              - name: "comment"
                description: "Add comments to code"
              - name: "cmd"
                description: "Generate shell command"

            allowAnonymousTelemetry: false

            ui:
              codeBlockRenderMode: "preview"
          '';

          ".continue/config.json".text = "";
        };
      };
    };
}
