{ lib, ... }: {

  flake.homeModules.base-hyprland = { pkgs, config, ... }: {
    options.hyprland.startupServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Modular bucket for adding Hyprland exec-once commands";
    };

    config.wayland.windowManager.hyprland.settings.exec-once = 
      config.hyprland.startupServices;
  };
}