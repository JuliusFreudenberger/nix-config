{
  inputs,
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
  };
}
