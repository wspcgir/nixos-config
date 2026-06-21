{ inputs, self, ... }: 
{
  flake.nixosConfigurations.desktop = 
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.home-manager.nixosModules.home-manager
        self.nixosModules.usb-wakeup-disable
        self.nixosModules.desktopModule
        self.nixosModules.storeOptimization
        self.nixosModules.home-jeff
      ];
  };
}
