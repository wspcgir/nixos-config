{ pkgs, ... }: 
{

  programs.kitty.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;

    plugins = with pkgs.hyprlandPlugins; [
      hyprexpo
    ];

    settings = {
      general = {
        # Remove space around windows
        gaps_out = 0;
        gaps_in = 0;
      };
      monitor = [ 
        ",preferred,auto,1" 
        "monitor=DP-4,2560x1440@169.83,1920x0,1"
      ];
      windowrule = [
        "noinitialfocus,floating:1,class:^(jetbrains-.*)$,title:^(win[0-9]+)$"
        "float,floating:1,class:^(jetbrains-.*)$,title:^(win[0-9]+)$"
      ];
      decoration = {
        # https://wiki.hypr.land/Configuring/Variables/#blur
        blur = {
          enabled = true;
          size = 6;
          new_optimizations = true;
          xray = true;
          popups = true;
        };
      };
      bind = [
        "SUPER+CTRL,Q,exec,hyprlock"
        ''SUPER,P,exec,grim -g "$(slurp)" - | swappy -f -''
        # bind to .
        "SUPER,code:60,exec,wofi-emoji"

        # Launch Applications
        "SUPER,Return,exec,alacritty"
        "SUPER,SPACE,exec,wofi --show drun"

        # Focused Window
        "SUPER,H,movefocus,l"
        "SUPER,J,movefocus,d"
        "SUPER,K,movefocus,u"
        "SUPER,L,movefocus,r"

        # Window Position 
        "SUPER+SHIFT,H,movewindow,l"
        "SUPER+SHIFT,J,movewindow,d"
        "SUPER+SHIFT,K,movewindow,u"
        "SUPER+SHIFT,L,movewindow,r"

        # Window Size
        "SUPER+ALT,H,resizeactive,-50 0"
        "SUPER+ALT,J,resizeactive,0 -50"
        "SUPER+ALT,K,resizeactive,0 50"
        "SUPER+ALT,L,resizeactive,50 0"

        # Window State
        "SUPER,Q,killactive"
        "SUPER,F,togglefloating,"

        # Workspace Focus
        "SUPER+CTRL,1,focusworkspaceoncurrentmonitor,1"
        "SUPER+CTRL,2,focusworkspaceoncurrentmonitor,2"
        "SUPER+CTRL,3,focusworkspaceoncurrentmonitor,3"
        "SUPER+CTRL,4,focusworkspaceoncurrentmonitor,4"
        "SUPER+CTRL,5,focusworkspaceoncurrentmonitor,5"
        "SUPER+CTRL,6,focusworkspaceoncurrentmonitor,6"
        "SUPER+CTRL,7,focusworkspaceoncurrentmonitor,7"
        "SUPER+CTRL,8,focusworkspaceoncurrentmonitor,8"
        "SUPER+CTRL,9,focusworkspaceoncurrentmonitor,9"
        "SUPER+CTRL,H,focusworkspaceoncurrentmonitor,m-1"
        "SUPER+CTRL,L,focusworkspaceoncurrentmonitor,m+1"
        "SUPER,mouse_up,focusworkspaceoncurrentmonitor,m+1"
        "SUPER,mouse_down,focusworkspaceoncurrentmonitor,m-1"
        "SUPER,TAB,hyprexpo:expo,toggle"

        # Workspace Windows 
        "SUPER+CTRL+SHIFT,1,movetoworkspacesilent,1"
        "SUPER+CTRL+SHIFT,2,movetoworkspacesilent,2"
        "SUPER+CTRL+SHIFT,3,movetoworkspacesilent,3"
        "SUPER+CTRL+SHIFT,4,movetoworkspacesilent,4"
        "SUPER+CTRL+SHIFT,5,movetoworkspacesilent,5"
        "SUPER+CTRL+SHIFT,6,movetoworkspacesilent,6"
        "SUPER+CTRL+SHIFT,7,movetoworkspacesilent,7"
        "SUPER+CTRL+SHIFT,8,movetoworkspacesilent,8"
        "SUPER+CTRL+SHIFT,9,movetoworkspacesilent,9"
        "SUPER+CTRL+SHIFT,H,movetoworkspacesilent,r-1"
        "SUPER+CTRL+SHIFT,L,movetoworkspacesilent,r+1"
        "SUPER,M,movetoworkspacesilent,emptym+1"

        # Volume Controls
        "CTRL,F6,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        "CTRL,F7,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ];
      bindm = [ 
        "SUPER,mouse:272,movewindow"
        "SUPER,mouse:273,resizewindow" 
      ];
      cursor = {
        # Prevents stutter when customizing 
        # the cursor
        no_hardware_cursors = true;
      };
      plugin = {
        hyprexpo = {
          columns = 3;
          gap_size = 5;
          bg_col = "rgb(111111)";
        };
      };
      misc = {
        # Makes resizing windows a bit smoother
        animate_manual_resizes = true;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };
      exec-once = [
        "waybar"
        "mako"
        "nm-applet"
        "hyprpaper"
        "blueman-applet"
        # For password prompts
        "lxsession"
      ];
      input = {
        kb_layout = "us";
        kb_options = [ "ctrl:nocaps" ];
        follow_mouse = 1;
        natural_scroll = true;
      };
    };
  };

  programs.waybar = {
    enable = true;
    style = builtins.readFile ./waybar/style.css;
    settings = [{
      layer = "top";
      position = "top";
      mod = "dock";
      exclusive = true;
      passthrough = false;
      gtk-layer-shell = true;
      height = 0;
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ ];
      modules-right = [ "pulseaudio" "custom/divider" "clock" "custom/space" ];
      pulseaudio = {
        format = "{icon} {volume}%";
        tooltip = false;
        format-muted = "Muted";
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
    }];
  };

  programs.wofi.enable = true;

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
      };
      background = [
        {
          color = "rgba(0,0,0,1.0)";
          blur_passes = 0;
        }
      ];
      input-field = [
        {
          size = "200, 50";
          position = "0m -80";
          monitor = "DP-4";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)"; 
          inner_color = "rgb(91, 96, 120)"; 
          outer_color = "rgb(24, 25, 38)"; 
          outline_thickness = 5;
        }
      ];
    };
  };

  services.mako.enable = true;

  services.hypridle.enable = true;

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "/home/jeff/Pictures/wallpapers/penrose_1.png"
        "/home/jeff/Pictures/wallpapers/penrose_2.png"
        "/home/jeff/Pictures/wallpapers/penrose_3.png"
        "/home/jeff/Pictures/wallpapers/penrose_4.png"
        "/home/jeff/Pictures/wallpapers/penrose_5.png"
        "/home/jeff/Pictures/wallpapers/penrose_6.png"
        "/home/jeff/Pictures/wallpapers/penrose_7.png"
        "/home/jeff/Pictures/wallpapers/penrose_8.png"
      ];
      wallpaper = [ ",/home/jeff/Pictures/wallpapers/penrose_1.png" ];
    };
  };

  services.wlsunset = {
    enable = true;
    latitude = 34.03;
    longitude = -118.35;
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        gtk-theme = "catppuccin-macchiato-mauve-compact";
        color-scheme = "prefer-dark";
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 12;
  };

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "macchiato";
        accent = "lavender";
      };
      name = "Papirus-Dark";
    };
    theme = {
      name = "catppuccin-macchiato-mauve-compact";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "macchiato";
        size = "compact";
      };
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
        gtk-overlay-scrolling=true
      '';
    };
  };


}
