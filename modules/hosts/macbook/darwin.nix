{self, ...}: {
  flake.darwinModules."macbook/darwin" = { pkgs,... }: {
    nix.settings.experimental-features = "nix-command flakes pipe-operators";
    fonts.packages = with pkgs; [ nerd-fonts.fira-code ];
    environment.systemPackages = [];
    nixpkgs.config.allowUnfree = true;
    system.configurationRevision = self.rev or self.dirtyRev or null;
    system.stateVersion = 6;
    nixpkgs.hostPlatform = "aarch64-darwin";
    users.users.jeffreydwyer = {
      name = "jeffreydwyer";
      home = "/Users/jeffreydwyer";
    };
  };
}