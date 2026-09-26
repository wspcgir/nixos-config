{ ... }: {
  flake.nixosModules."desktop/jellyfin" = { ... }: let 
    drive = (import ./static/_drives.nix).wd14tb;
  in {
      services.jellyfin = {
        enable = true;
        openFirewall = true;
        user = "jeff";
      };
      systemd.services.jellyfin = {
        unitConfig = {
          RequiresMountsFor = [ drive.extMount ];
          BindsTo = [ drive.mountUnit ];
          After = [ drive.mountUnit ];
        };
      };
  };
}