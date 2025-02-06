{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    libreoffice-fresh
    hunspell hyphen
    hunspellDicts.en_US hyphenDicts.en_US
    hunspellDicts.de_DE hyphenDicts.de_DE

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
      epson-escpr
      epson-escpr2
    ];
  };

}
