{
  description = "NixOS flake";
  inputs = {
    # Nix package set
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Utilities for structuring the configuration
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Utility for auto importing configuration files
    import-tree.url = "github:vic/import-tree";

    # MacOS Configuration
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Modules to define user packages, services and dot files
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets management within config
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Neovim configuration modules
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Music track classifier 
    music-curator = { 
      url = "github:wspcgir/music-library-curator";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { self, lib, ... }:
      let
        # The root of the project, useful for referencing files
        # without needing lots of ../../..
        flakeRoot = ./.;
      in
      {

        config = {
          # All of the supported systems the configuratiosn support
          systems = [
            "x86_64-linux"
            "aarch64-darwin"
          ];

          _module.args = {
            inherit flakeRoot;
          };

          perSystem = { system, ... }: {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
              };
            };
          };

        };

        options.flake = {
          darwinModules = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.deferredModule;
            default = { };
            description = "A set of reusable nix-darwin modules exported by this flake.";
          };
        };

        # Use import-tree to auto import everything in
        # the modules directory
        imports = [
          inputs.home-manager.flakeModules.home-manager
          (inputs.import-tree ./modules)
        ];
      }
    );
}
