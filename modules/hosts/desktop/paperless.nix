{ ... }: {
  flake.nixosModules."desktop/paperless" = { ... }: let 
    drive = (import ./static/_drives.nix).wd14tb;
    consumptionDir = "${drive.extMount}/books";
    mediaDir = "${drive.extMount}/paperless";
    mountUnits = {
      unitConfig = {
        RequiresMountsFor = [ drive.extMount ];
        BindsTo = [ drive.mountUnit ];
        After = [ drive.mountUnit ];
        ConditionPathIsMountPoit = drive.extMount;
      };
      serviceConfig = {
        ReadWritePaths = [
          # The + tells systemd to not fail if the path doesn't exist
          "+${consumptionDir}"
          "+${mediaDir}"
        ];
      };
    };
  in {

    services.paperless = {
      enable = true;
      address = "127.0.0.1";
      port = 28981;
      dataDir = "/var/lib/paperless";
      inherit consumptionDir mediaDir;
      settings = {
        PAPERLESS_OCR_MODE = "skip";
        PAPERLESS_OCR_LANGUAGE = "eng";
        PAPERLESS_AUTO_LOGIN_USERNAME = "admin";
        PAPERLESS_FILENAME_FORMAT = "{created_year}/{correspondent}/{title}";
      };
    };

    systemd.services.paperless-consumer = mountUnits;
    systemd.services.paperless-web = mountUnits; 
    systemd.services.paperless-scheduler = mountUnits; 
    systemd.services.paperless-task-queue = mountUnits; 

    users.groups.paperless.members = [ "jeff" ];
  };
}