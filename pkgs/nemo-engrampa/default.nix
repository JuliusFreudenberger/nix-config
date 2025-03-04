{
  stdenv,
  lib,
  fetchFromGitHub,
  meson,
  pkg-config,
  ninja,
  glib,
  gtk3,
  nemo,
  mate,
  cinnamon-translations,
}:

stdenv.mkDerivation rec {
  pname = "nemo-engrampa";
  version = "6.2.0";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "nemo-extensions";
    rev = version;
    hash = "sha256-qghGgd+OWYiXvcGUfgiQT6rR4mJPAOfOtYB3lWLg4iA=";
  };

  sourceRoot = "${src.name}/nemo-fileroller";

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ];

  buildInputs = [
    glib
    gtk3
    nemo
  ];

  postPatch = ''
    pushd src
    for file in *fileroller* ; do
      mv "''${file}" "''${file/fileroller/engrampa}"
    done
    popd
    substituteInPlace src/nemo-engrampa.c \
      --replace-fail "file-roller" "${lib.getExe mate.engrampa}" \
      --replace-fail "fileroller" "engrampa" \
      --replace-fail "FileRoller" "Engrampa" \
      --replace-quiet "GNOMELOCALEDIR" "${cinnamon-translations}/share/locale"
    substituteInPlace src/engrampa-module.c \
      --replace-fail "fileroller" "engrampa"
    substituteInPlace src/meson.build \
      --replace-fail "fileroller" "engrampa"
  '';

  PKG_CONFIG_LIBNEMO_EXTENSION_EXTENSIONDIR = "${placeholder "out"}/${nemo.extensiondir}";

  meta = {
    homepage = "https://github.com/linuxmint/nemo-extensions/tree/master/nemo-fileroller";
    description = "Nemo engrampa extension";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ JuliusFreudenberger ];
  };
}
