{ self, lib, ... }: {

  flake.homeModules.waybar = { pkgs, config, ... }: {

    programs.waybar = {
      enable = true;
      style = builtins.readFile ./waybar/_style.css;
      settings = [
        {
          layer = "top";
          position = "top";
          mod = "dock";
          exclusive = true;
          passthrough = false;
          gtk-layer-shell = true;
          height = 0;
          "reload_style_on_change" = true;
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ ];
          modules-right = [
            "tray"
            "custom/divider"
            "cpu"
            "custom/divider"
            "memory"
            "custom/divider"
            "network"
            "custom/divider"
            "pulseaudio"
            "custom/divider"
            "clock"
            "custom/space"
          ];
          tray = {
            icon-size = 8;
            spacing = 10;
            show-passive-items = true;
          };
          cpu = {
            interval = 10;
            format = "🧠{usage}%";
            tooltip = false;
          };
          memory = {
            interval = 10;
            format = "🐏{}%";
          };
          pulseaudio = {
            format = "{icon} {volume}%";
            tooltip = false;
            format-muted = "Muted";
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
            format-icons = {
              headphone = "🎧";
              default = [ "🔈" "🔉" "🔊" ];
            };
          };
          network = {
            format-ethernet = "📡 {ipaddr}/{cidr}";
            format-disconnected = "Disconnected";
          };
          "custom/divider" = {
            format = " | ";
            interval = "once";
            tooltip = false;
          };
          "custom/space" = {
            format = " ";
            interval = "once";
            tooltip = false;
          };
        }
      ];
    };
  };
}
