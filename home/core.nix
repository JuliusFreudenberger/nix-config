{username, ...}: {
  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    preferXdgDirectories = true;

    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
