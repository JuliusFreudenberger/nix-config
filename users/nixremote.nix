{
  ...
}: {
  users.users = {
    nixremote = {
      isNormalUser = true;
      uid = 1100;
      group = "users";
    };
  };

  nix.settings.trusted-users = [ "nixremote" ];
}
