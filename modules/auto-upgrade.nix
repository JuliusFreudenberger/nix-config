{
  inputs,
  pkgs,
  ...
}: {
  system.autoUpgrade = {
    enable = true;
    flags = [
      "--recreate-lock-file" # Deprecated, but will hopefully be reintroduced
      "-L"
    ];
    flake = inputs.self.outPath;
    dates = "02:00";
    randomizedDelaySec = "45min";
    allowReboot = true;
    rebootWindow = {
      lower = "01:00";
      upper = "05:00";
    };
  };

  # Also needs access to the nix-private repo which contains the encrypted secrets
  programs.ssh = {
    extraConfig = "
      Host git.jfreudenberger.de
        Port 222
        User git
        IdentityFile /etc/ssh/ssh_host_ed25519_key
    ";
    knownHostsFiles = [
      (pkgs.writeText "forgejo.keys" ''[git.jfreudenberger.de]:222 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK+uqIeb9+AoqwD0Z6xLKI2dsRoS9Qh/VwboYfGpBJd+
[git.jfreudenberger.de]:222 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8GDSt4LsCzOoIZkqZRLgXyTLyHoJu62cFFP88i8GpSadyV6mJPkK5p2mgBzN/BM9I/G2VWfvqdM8Fy/7p3S8kDhmmkOk1AK7C/+qaQKsKcQauJuzNXlwMHG1Ivath80TO9PIQc9jYakP9xl8SACd5bwkvfEm3rS5awZ8T2hWgnsgO8pFHFOFmFnVbujXZk58FVTCxpgyPqjFv76JSYxpHk1VtiQ52jScsreOImEOWWg88f9IM9etWcshuxte4zudaqc2KjjAB6pYMuVj7O6cwMXKjCUxTzyomWjr2JoEruIslifbZ6bJGgswg5ENJSKURuMPgTuGM6Nrjp75V/yFD
[git.jfreudenberger.de]:222 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOS447cAWRZgHPs6MOoRS6/J66oY753QPiM7BI63/qNDd5qrCan153dJd5lBGwDR0vMWiV/0cmzuACfP5QS1Lv8=
    '')
    ];
  };
}
