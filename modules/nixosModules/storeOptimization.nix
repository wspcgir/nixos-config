{ withSystem, ... }: {

  flake.nixosModules.storeOptimization = withSystem "x86_64-linux" (
    { pkgs, inputs', ... }: {
      # Auto replace duplicate files in the nix store
      # with hard links
      nix.settings.auto-optimise-store = true;

      # Setup automatic garbage collection
      nix.gc.automatic = true;
      nix.gc.dates = "*-*-0/2";
      nix.gc.options = "--delete-older-than 7d";
    }
  );
}
