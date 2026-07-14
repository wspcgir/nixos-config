{ ... }: {

  flake.homeModules.wallpaperSwitcher =
    { pkgs, config, ... }:

    let
      workspace-wallpaper = with config.common-lib.colors; pkgs.writeShellScriptBin "workspace-wallpaper" ''
        # Map workspace IDs to Hex colors (awww expects pure RRGGBB hex format)
        get_color() {
          case "$1" in
            "1")  echo "${lavender}"
            "2")  echo "${peach}" 
            "3")  echo "${sapphire}" 
            "4")  echo "${maroon}" 
            "5")  echo "${teal}" 
            "6")  echo "${flamingo}" 
            "7")  echo "${green}" 
            "8")  echo "${mauve}" 
            "9")  echo "${yellow}" 
            "10") echo "${rosewater}" 
            *)    echo "${default}"
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
