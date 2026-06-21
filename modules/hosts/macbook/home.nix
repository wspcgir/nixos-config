{ self, ... }: {

  flake.darwinModules."macbook/home" = { ... }: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.jeffreydwyer = { pkgs, ...}: {

      home.username = "jeffreydwyer";
      home.homeDirectory = "/Users/jeffreydwyer";
  
      imports = [ 
        self.homeModules.nvf
        self.homeModules.zsh
        self.homeModules.yazi
        self.homeModules.vscodeCustom
        self.homeModules.git
        self.homeModules.direnv
      ];
  
      home.packages = let 
        from-nixpkgs = with pkgs; [
          nil # Nix IDE
          rclone # file transfer
          streamrip # music downloading
          yt-dlp # Youtube downloader
        ];
        from-self = [];
      in from-nixpkgs ++ from-self;
  
      programs.bash = { enable = true; };

      programs.vscodium.custom = {
        enable = true;
      };
  
      home.stateVersion = "25.05";
    };
  };
}
