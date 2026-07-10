{ ... }: {
  perSystem =
    { pkgs, ... }:
    {
      packages.usb-restart = pkgs.writeShellApplication {
        name = "usb-restart";

        runtimeInputs = [
          pkgs.coreutils
          pkgs.coreutils
          pkgs.kmod
          pkgs.coreutils
          pkgs.kmod
        ];

        text = ''
          echo "Starting usb-restart"
          echo "Disabling usb port 6"
          modprobe -r xhci_pci
          echo "Enabling usb port 6"
          modprobe xhci_pci
        '';
      };

    };
}
