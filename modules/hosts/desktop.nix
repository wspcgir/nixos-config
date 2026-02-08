{ inputs, self, ... }: 
{
  flake.nixosConfigurations.desktop = 
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.usb-wakeup-disable
        self.nixosModules.desktopModule
        inputs.home-manager.nixosModules.home-manager
        self.nixosModules.home-jeff
      ];
  };
}
