{ stdenv
, lib
, fetchFromGitLab
, bash
, scrot
, xdg-user-dirs
, libnotify
, xclip
, makeWrapper
}: let
    pname = "i3-scrot";
  in
  stdenv.mkDerivation rec {
    name = pname;
    version = "1-unstable-a6f3fa1c";
    src = fetchFromGitLab {
      owner = "packages/extra";
      repo = pname;
      domain = "gitlab.manjaro.org";
      rev = "a6f3fa1cb127b0ae8c08cfd1fccd55c9ac07abd4";
      sha256 = "sha256-1tbZnMLrMYV3IJa9LLve3kdZ+dxXiSyN0orgvIm1sR0=";
    };
    buildInputs = [ bash scrot libnotify xclip ];
    nativeBuildInputs = [ makeWrapper ];

    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin
      cp i3-scrot $out/bin/i3-scrot
      chmod +x $out/bin/i3-scrot
      wrapProgram $out/bin/i3-scrot \
        --prefix PATH : ${lib.makeBinPath [ bash scrot xdg-user-dirs libnotify xclip ]}
    '';
    
    meta = with lib; {
      platforms = platforms.all;
    };
  }

