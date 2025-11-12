{ config, pkgs, ... }:

{
  system.stateVersion = "25.05";

  # Nix Settings
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./usb-wakeup-disable.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sdb";
  boot.loader.grub.useOSProber = true;

  boot.kernelParams = [ 
    # These help fix an issue with an external
    # drive getting lost after suspends 
    "usbcore.autosuspend=-1"
    "xhci_hcd.quirks=270336" 
  ];

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Locale
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Graphics and Desktop 
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    xkb = {
      layout = "us";
      variant = "";
    };
  };
  hardware.nvidia = {
    # Use the open source drivers
    # Recommended for RTX 20-Series
    open = false;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
  };

  # For Login screen
  services.displayManager.sddm.enable = true;
  programs.hyprland.enable = true;
  # For running commands as sudo
  security.polkit.enable = true;

  # Enable for external drive discovery
  # and auto mounting
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.devmon.enable = true;

  programs.fuse.userAllowOther = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.usb.wakeupDisabled = [
    # Keyboard
    {
      vendor = "04b4";
      product = "0818";
    }
    # Mouse
    {
      vendor = "25a7";
      product = "fa07";
    }
  ];

  # System Packages
  environment.systemPackages = with pkgs; [
    usbutils
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    ntfs3g
  ];
  systemd.services.usb-restart = {
    enable = true;
    description = "Restart USBs after suspension";
    after = [ "suspend.target" ];
    wantedBy = [ "suspend.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "usb-restart" ''
          ${pkgs.coreutils}/bin/echo "Starting usb-restart"
          ${pkgs.coreutils}/bin/echo "Disabling usb port 6"
          ${pkgs.kmod}/bin/modprobe -r xhci_pci
          ${pkgs.coreutils}/bin/echo "Enabling usb port 6"
        	${pkgs.kmod}/bin/modprobe xhci_pci
      ''}";
    };
  };
  systemd.services."systemd-suspend" = {
    serviceConfig = {
      Environment = ''"SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false"'';
    };
  };

  # User Packages
  users.users.jeff = {
    isNormalUser = true;
    description = "Jeff";
    extraGroups = [
      "networkmanager"
      "wheel"
      # For Android Studio
      "kvm"
      "adbusers"
      # For Nvidia
      "video"
      # For autoloading external drives
      "storage"
      # For cryptomator
      "fuse"
    ];
    packages = with pkgs; [
      aichat # LLM terminal interface
      age # secrets generation
      android-studio
      cryptomator # encrypted vault manager
      # disabled until I can figure out
      # how to block history for KeePassXC
      # cliphist # Clipboard history 
      discord # social app
      grim # Wayland Screenshots
      gnucash # accounting
      hledger # cli accounting
      jackett # torrent tracker
      keepassxc # password manager
      libreoffice-qt # office stuff
      lxsession # gui sudoo entry
      musescore # music notation
      # nautilus # file manager separate from gnome
      nil # nix LSP server
      nixfmt-classic # Nix code formatter
      obsidian # notes
      pavucontrol # GUI for audio devices 
      quodlibet # music player and library manager
      rsync # file sync, mainly for playlist sync
      sops # secrets
      slurp # Wayland region selector (screenshots)
      swappy # Screenshot annotator
      ueberzugpp # image rendering in terminal via X11
      vivaldi # web browser
      vlc # media player
      whatsie # whatsapp client
      wf-recorder # Screen recording
      wl-clipboard # Wayland terminal Copy/Pasting command
      wofi-emoji # emoji picker
      zoom-us
    ];
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.dejavu-sans-mono
  ];

  # For Android Studio
  programs.adb.enable = true;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "jeff";
  };

  services.jackett.enable = true;

  services.ollama = {
    enable = true;
    acceleration = "cuda";
    loadModels = [ "qwen3:8b" "deepseek-coder:6.7b" "embeddinggemma:300m" ];
  };
}
