{ ... }: {

  flake.homeModules.wallpaperSwitcher =
    { pkgs, config, ... }:

    let
      workspace-wallpaper = pkgs.writeShellScriptBin "workspace-wallpaper" ''
        # Map workspace IDs to Hex colors (awww expects pure RRGGBB hex format)
        get_color() {
          case "$1" in
            "1")  echo "b4befe" ;; # Lavender
            "2")  echo "fab387" ;; # Peach
            "3")  echo "74c7ec" ;; # Sapphire
            "4")  echo "eba0ac" ;; # Maroon
            "5")  echo "89dceb" ;; # Teal
            "6")  echo "f2cdcd" ;; # Flamingo
            "7")  echo "a6e3a1" ;; # Green
            "8")  echo "cba6f7" ;; # Mauve
            "9")  echo "f9e2af" ;; # Yellow
            "10") echo "f5e0dc" ;; # Rosewater
            *)    echo "313244" ;; # Fallback
          esac
        }

        update_monitor_color() {
          local mon="$1"
          local ws_id=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r ".[] | select(.name == \"$mon\") | .activeWorkspace.id")
          
          if [ -n "$ws_id" ] && [ "$ws_id" != "null" ]; then
            local color=$(get_color "$ws_id")
            # awww clear updates a specific monitor instantly to a solid hex color
            ${pkgs.awww}/bin/awww clear -o "$mon" "$color"
          fi
        }

        # Wait for awww-daemon to be fully ready before sending initial colors
        until ${pkgs.awww}/bin/awww query &>/dev/null; do
          sleep 0.1
        done

        # Initial paint
        hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | .name' | while read -r mon; do
          update_monitor_color "$mon"
        done

        # Listen to the Hyprland IPC socket
        ${pkgs.socat}/bin/socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
          if echo "$line" | grep -qE "^(workspace|focusedmon)>>"; then
            ACTIVE_MON=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused == true) | .name')
            update_monitor_color "$ACTIVE_MON"
          fi
        done
      '';
    in
    {
      # Disable hyprpaper service if you had it elsewhere:
      # services.hyprpaper.enable = false;

      home.packages = [
        pkgs.jq
        pkgs.socat
        pkgs.awww
        workspace-wallpaper
      ];

      hyprland.startupServices = [
        # Start the awww daemon background process
        "${pkgs.awww}/bin/awww-daemon"
        # Start our workspace tracking daemon
        "${workspace-wallpaper}/bin/workspace-wallpaper"
      ];

      wayland.windowManager.hyprland.enable = true;
    };
}
