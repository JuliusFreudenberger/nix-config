{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    jetbrains.idea
    jetbrains.pycharm

    vscodium-fhs
    zed-editor.fhs

    k6

    (pkgs.lazy-app.override {
      pkg = pkgs.dbeaver-bin;
      desktopItem = pkgs.makeDesktopItem {
        name = "DBeaver";
        exec = "env NO_AT_BRIDGE=1 dbeaver %U";
        icon = "dbeaver";
        desktopName = "DBeaver";
        comment = "SQL Integrated Development Environment";
        categories = [ "IDE" "Development" ];
        mimeTypes = [
          "application/sql"
        ];
      };
    })
  ];

}
