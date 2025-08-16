{
  pkgs,
  lib,
  ...
}: {

  services.k3s = {
    enable = true;
    role = "server";
    clusterInit = true;
    token = "verysecrettoken";
    extraFlags = toString ([
      "--write-kubeconfig-mode \"0644\""
      "--disable servicelb"
      "--disable traefik"
      "--disable local-storage"
    ]);
  };

  networking.firewall.allowedTCPPorts = [
    6443
  ];
  networking.firewall.allowedUDPPorts = [
    8472
  ];

}
