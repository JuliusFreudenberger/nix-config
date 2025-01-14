{ stdenv
, lib
, fetchFromGitHub
, bash
, gawk
, firefox
, rofi
, makeWrapper
}: let
    pname = "rofirefox";
  in
  stdenv.mkDerivation rec {
    name = pname;
    version = "cc14b76";
    src = fetchFromGitHub {
      owner = "ethmtrgt";
      repo = pname;
      rev = "cc14b76c4cea3263bd8c421f479089503271847b";
      sha256 = "ngtK31X9XyLKoHBfI8SOYbzyvW/LQBE9kq0wNhnxnP0=";
    };
    buildInputs = [ bash gawk firefox rofi ];
    nativeBuildInputs = [ makeWrapper ];

    dontBuild = true;

    patches = [
      ./case-sensitivity.patch
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp rofirefox.sh $out/bin/rofirefox
      chmod +x $out/bin/rofirefox
      wrapProgram $out/bin/rofirefox \
        --prefix PATH : ${lib.makeBinPath [ bash gawk firefox rofi ]}
    '';
    
    meta = with lib; {
      platforms = platforms.all;
    };
  }

