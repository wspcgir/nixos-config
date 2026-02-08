{ self, ... }: {

    flake.nixosConfigurations.nixos = self.nixosConfigurations.desktop;
}
