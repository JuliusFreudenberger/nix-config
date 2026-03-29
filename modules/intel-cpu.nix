{
  pkgs,
  ...
}: {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # Enable Hardware Acceleration
      vpl-gpu-rt # Enable QSV
    ];
  };
}
