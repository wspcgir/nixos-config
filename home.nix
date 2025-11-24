{ inputs, pkgs, ... }:

let
  home-dir = "/home/jeff";
  external-drive-dir = "/run/media/jeff/easystore";
in {
  home.username = "jeff";
  home.homeDirectory = home-dir;

  imports = [ 
    (import ./home/sops.nix { inherit home-dir; })
    (import ./home/hyprland.nix)
    (import ./home/yazi.nix)
    (import ./home/editors.nix)
    (import ./home/zsh.nix)
  ];

  home.packages = with pkgs; [
    alacritty # terminal
    direnv
    glance # dashboards
    kitty # required by hyprland
    rclone # file transfer
    streamrip # music downloading
    telegram-desktop
    vscode
    wlsunset # screen temperature
    yazi
    zoxide
  ];

  programs.bash = { enable = true; };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font.normal = {
        family = "Dejavu Sans Mono";
        style = "Regular";
      };
      terminal.shell = {
        program = "zsh";
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "JD95";
    userEmail = "jeffreydwyer95@outlook.com";
    extraConfig = {
      diff.tool = "vimdiff";
    };
  };

  systemd.user.services.sync-google-drive = {
    Unit = { Description = "Sync Google Drive"; };
    Install = { WantedBy = [ "default.target" ]; };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "sync-google-drive" ''
        ${pkgs.coreutils}/bin/echo "Starting sync of google drive"
        ${pkgs.rclone}/bin/rclone bisync \
            --resync \
            "google:/" "${external-drive-dir}/google-drive" \
            --compare size,modtime,checksum \
            --modify-window 1s \
            --create-empty-src-dirs \
            --drive-acknowledge-abuse \
            --drive-skip-gdocs \
            --drive-skip-shortcuts \
            --drive-skip-dangling-shortcuts \
            --metadata \
            --progress \
            --verbose \
            --log-file "${home-dir}/.config/rclone/rclone.log" 
      ''}";
    };
  };

  systemd.user.services.cycle-wallpaper = {
    Unit = { Description = "Cycles Wallpapers managed by Hyprpaper"; };

    Install = {

      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = let
        script = pkgs.writeShellApplication {
          name = "cycle-wallpaper";

          runtimeInputs = with pkgs; [ hyprland coreutils ];

          text = ''
            WALLPAPER_DIR="$HOME/Pictures/wallpapers"
            CURRENT_WALL=$(hyprctl hyprpaper listloaded | grep wallpaper | sed 's/wallpaper=,,//')

            # If no wallpaper is currently loaded, select any image
            if [ -z "$CURRENT_WALL" ]; then
              WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" \) | shuf -n 1)
            else
              # Otherwise, pick a random wallpaper that is not the current one
              WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" \) ! -name "$(basename "$CURRENT_WALL")" | shuf -n 1)
            fi

            # Apply the new wallpaper
            if [ -n "$WALLPAPER" ]; then
              hyprctl hyprpaper reload ,"$WALLPAPER"
            fi 
          '';
        };
      in "${script}/bin/cycle-wallpaper";
    };
  };


  home.stateVersion = "25.05";
}
