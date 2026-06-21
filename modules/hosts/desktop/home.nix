{ self, ... }: {

  flake.nixosModules."desktop/home" = { ... }: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.jeff = { pkgs, ...}: {

      home.username = "jeff";
      home.homeDirectory = "/home/jeff";
  
      imports = [ 
        self.homeModules.sops
        self.homeModules.nvf
        self.homeModules.zsh
        self.homeModules.yazi
        self.homeModules.vscodeCustom
        self.homeModules.git
        self.homeModules.alacritty
        self.homeModules.direnv
        self.homeModules.udiskie
        self.homeModules.hyprland
      ];
  
      home.packages = let 
        from-nixpkgs = with pkgs; [
          glance # dashboards
          kitty # required by hyprland
          rclone # file transfer
          streamrip # music downloading
          telegram-desktop
          wlsunset # screen temperature
          yt-dlp # Youtube downloader
        ];
        from-self = [
          self.packages.${pkgs.stdenv.hostPlatform.system}.gdrive-sync-all
          self.packages.${pkgs.stdenv.hostPlatform.system}.gdrive-sync
        ];
      in from-nixpkgs ++ from-self;
  
      programs.bash = { enable = true; };

      programs.vscodium.custom = {
        enable = true;
        languages.nix.enable = true;
        languages.haskell.enable = true;
        languages.rust.enable = true;
        continue.enable = true;
      };
  
      home.stateVersion = "25.05";
    };
  };
}
