{
  description = "NixOS flake";
  inputs = {
    # Nix package set, pinned to version 25.11
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Nix package set, unstable (latest versions) 
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Utilities for structuring the configuration
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Utility for auto importing configuration files
    import-tree.url = "github:vic/import-tree";

    # Modules to define user packages, services and dot files 
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets management within config 
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Neovim configuration modules
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  }; 

  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } ({ self, ... }: 
  let 
      # The root of the project, useful for referencing files 
      # without needing lots of ../../..
      flakeRoot = ./.;
  in { 

    # All of the supported systems the configuratiosn support 
    systems = [ "x86_64-linux" ];

    _module.args = {
      inherit flakeRoot;
    };

    perSystem = { system, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "qtwebengine-5.15.19" ];
        };
      };
    };


    # Use import-tree to auto import everything in 
    # the modules directory
    imports = [
      inputs.home-manager.flakeModules.home-manager
      (inputs.import-tree ./modules)
    ];
  });
}
