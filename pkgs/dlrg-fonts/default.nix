{ stdenv, lib, requireFile, pkgs }: let
  in
  stdenv.mkDerivation rec {
    name = "dlrg-fonts";
    version = "0-unstable-2019-11-19";
    src = requireFile {
      name = "DLRG-Schriftart.zip";
      hash = "sha256-z+VH8rIeAsJhbqfRh57ryXj+RYU0kWbLcpIivbXA0sk=";
      url = "https://dlrg.net/apps/dokumente?page=assetService&noheader=1&aid=1709&v=o&file=DLRG%20Schriftart.zip";
    };

    unpackPhase = ''
      runHook preUnpack
      ${pkgs.unzip}/bin/unzip $src

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      install -Dm644 *.TTF -t $out/share/fonts/truetype

      runHook postInstall
    '';
    
    meta = with lib; {
      platforms = platforms.all;
    };
  }

