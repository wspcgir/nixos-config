{ self, inputs, ... }: {

    flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.home-manager.nixosModules.home-manager
          self.nixosModules."desktop/nixos"
          self.nixosModules."desktop/home"
          self.nixosModules.usb-wakeup-disable
          self.nixosModules.storeOptimization
        ];
    };
}
