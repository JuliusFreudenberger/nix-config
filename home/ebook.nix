{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs; [
    # See: https://github.com/Leseratte10/acsm-calibre-plugin/issues/68#issuecomment-2162686156
    (pkgs.calibre.overrideAttrs (old: {
      postInstall = ''
        wrapProgram $out/bin/calibre \
            --set-default ACSM_LIBCRYPTO ${pkgs.openssl.out}/lib/libcrypto.so \
            --set-default ACSM_LIBSSL ${pkgs.openssl.out}/lib/libssl.so
      '';
    }))
  ];
}
