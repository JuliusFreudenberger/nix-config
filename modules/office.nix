{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    libreoffice-fresh
    xournalpp

    system-config-printer

    simple-scan
    #naps2

    baobab
  ];


  services.printing = {
    enable = true;
    drivers = with pkgs; [ 
      gutenprint
      #epson-escpr
      epson-escpr2
    ];
  };

}
