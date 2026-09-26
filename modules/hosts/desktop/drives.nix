{ ... }: {
  flake.nixosModules."desktop/drives" = let 
    drives = import ./static/_drives.nix;
  in {
    fileSystems."${drives.wd14tb.extMount}" = {
      device = "/dev/disk/by-uuid/${drives.wd14tb.uuid}";
      fsType = drives.wd14tb.fileSystem;
      options = [ "nofail" "x-systemd.automount" ];
    };
  };
}