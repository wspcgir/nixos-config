{ self, inputs, ... }: {

  flake.darwinConfigurations."Jeffreys-MacBook-Air" = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      inputs.home-manager.darwinModules.home-manager
      self.darwinModules."macbook/darwin"
      self.darwinModules."macbook/home"
    ];
  };
}
