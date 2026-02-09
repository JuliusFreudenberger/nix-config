{
  ...
}: let
  t27 = "Lenovo Group Limited T27h-30 V5HGY026";
in {
  services.kanshi = {
    enable = true;
    settings = [
      { output.criteria = "eDP-1"; output.scale = 1.0; }
      { output.criteria = t27; }
      { profile.name = "mobile";
        profile.outputs = [
          { criteria = "eDP-1"; }
        ];
      }
      { profile.name = "t27" ;
        profile.outputs = [
          { criteria = "eDP-1"; position = "152,1440"; }
          { criteria = t27; position = "0,0"; }
        ];
      }
    ];
  };
}
