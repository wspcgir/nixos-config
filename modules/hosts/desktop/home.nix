{ self, inputs, ... }: {

  flake.nixosModules."desktop/home" = { ... }: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.jeff = { pkgs, ... }: {

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
        self.homeModules.wallpaperSwitcher
      ];

      home.packages =
        let
          from-nixpkgs = with pkgs; [
            cavasik # Audio visualizer
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
          from-flakes = [
            inputs.music-curator.packages.${pkgs.stdenv.hostPlatform.system}.music-curator
          ];
        in
        from-nixpkgs ++ from-self ++ from-flakes;

      programs.bash = {
        enable = true;
      };

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
