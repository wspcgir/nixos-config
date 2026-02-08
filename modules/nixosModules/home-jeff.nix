{ self, ... }: {

  flake.nixosModules.home-jeff = { ... }: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.jeff = self.homeModules.jeff; 
  };
}
