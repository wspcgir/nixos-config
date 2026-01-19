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

  home.stateVersion = "25.05";
}
