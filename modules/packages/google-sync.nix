{ ... }:
{

  perSystem =
    {
      config,
      pkgs,
      system,
      ...
    }:
    let
      commonInputs = with pkgs; [
        rclone
        coreutils
      ];
    in
    {
      packages.gdrive-sync-all = pkgs.writeShellApplication {
        name = "gdrive-sync-all";

        runtimeInputs = commonInputs;

        text = ''
          DRIVE_DIR="$1"
          rclone bisync \
              --resync \
              "google:/" "$DRIVE_DIR" \
              --compare size,modtime,checksum \
              --modify-window 1s \
              --create-empty-src-dirs \
              --drive-acknowledge-abuse \
              --drive-skip-gdocs \
              --drive-skip-shortcuts \
              --drive-skip-dangling-shortcuts \
              --metadata \
              --progress \
              --verbose
        '';
      };

      packages.gdrive-sync = pkgs.writeShellApplication {
        name = "gdrive-sync";
        runtimeInputs = commonInputs;
        text = ''
          DIRECTION="$1"
          LOCAL_PATH="$2"
          if [ "$DIRECTION" == "pull" ]; then
            rclone copyto "google:$LOCAL_PATH" "$LOCAL_PATH" --progress --verbose
          elif [ "$DIRECTION" == "push" ]; then
            rclone copyto "$LOCAL_PATH" "google:$LOCAL_PATH" --progress --verbose
          else 
            echo "ERROR: use 'push' or 'pull' as the first argument."
          fi 
        '';
      };
    };
}
