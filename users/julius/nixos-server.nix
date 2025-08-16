{
  ...
}: {

  users = {
    users = {
      julius = {
        initialPassword = "password";
        isNormalUser = true;
        uid = 1000;
        group = "julius";
        extraGroups = [ "wheel" ];
      };
    };
    groups = {
      julius = {
        gid = 1000;
      };
    };
  };

  nix.settings.trusted-users = [ "julius" ];
}
