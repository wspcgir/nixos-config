{ flakeRoot, inputs, ... }: {

  flake.homeModules."jeff/sops" = { self, ... }: {

    imports = [ inputs.sops-nix.homeManagerModules.sops ];

    sops = {
      age.keyFile = "/home/jeff/.config/sops/age/keys.txt";
      defaultSopsFile = "${flakeRoot}/secrets.yaml";
      secrets = {
        "accounts/google/user" = { };
        "accounts/google/pass" = { };
        "services/glance/feeds/politics" = { 
          format = "yaml";
        };
      };
    };
  };
}
