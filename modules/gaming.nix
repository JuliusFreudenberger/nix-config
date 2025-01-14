{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [

  ];

  programs = {
    steam.enable = true;
  };

}
