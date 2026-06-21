{...}: {
  flake.homeModules.git = {...}: {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "JD95";
          email = "jeffreydwyer95@outlook.com";
        };
        diff.tool = "vimdiff";
      };
    };
  };
}