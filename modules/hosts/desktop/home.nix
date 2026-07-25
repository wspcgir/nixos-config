{ self, inputs, ... }: {

  flake.nixosModules."desktop/home" = { ... }: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.jeff = { pkgs, ... }: let
      selfPackages = self.packages.${pkgs.stdenv.hostPlatform.system};
    in {

      home.username = "jeff";
      home.homeDirectory = "/home/jeff";

      imports = [
        self.homeModules.alacritty
        self.homeModules.base-hyprland
        self.homeModules.direnv
        self.homeModules.git
        self.homeModules.hyprland
        self.homeModules.nushell
        self.homeModules.nvf
        self.homeModules.sops
        self.homeModules.udiskie
        self.homeModules.vscodeCustom
        self.homeModules.wallpaperSwitcher
        self.homeModules.waybar
        self.homeModules.yazi
        self.homeModules.zsh
      ];

      home.packages =
        let
          from-nixpkgs = with pkgs; [
            cavasik # Audio visualizer
            gitu # Git CLI
            glance # dashboards
            kitty # required by hyprland
            rclone # file transfer
            streamrip # music downloading
            telegram-desktop
            wlsunset # screen temperature
            yt-dlp # Youtube downloader
          ];
          from-self = with selfPackages; [
            gdrive-sync-all
            gdrive-sync
            usb-restart
          ];
          from-flakes = [
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
        languages.nushell.enable = true;
        continue.enable = true;
      };

      home.stateVersion = "25.05";
    };
  };
}
