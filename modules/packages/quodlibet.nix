{ ... }: {
  perSystem = { pkgs, ... }: {
    packages.quodlibet = pkgs.symlinkJoin {
      name = "quodlibet";
      paths = [ pkgs.quodlibet ];
      postBuild = ''
      rm "$out/bin/quodlibet"
      cat <<EOF > "$out/bin/quodlibet"
#!/bin/sh
export GDK_BACKEND=x11
exec ${pkgs.quodlibet}/bin/quodlibet "\$@"
EOF
      chmod +x "$out/bin/quodlibet"
    '';
    };
  };
}
