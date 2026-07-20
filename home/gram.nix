{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  gram-extensions,
  ...
}:
  let
    extensions = with gram-extensions; [
      typst
      git-firefly
    ];
    extensions-dir = gram-extensions.linkGramExtensions extensions;
  in {
  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.gram;
    extraPackages = [
      pkgs.nil
      pkgs.tinymist
      pkgs.tofu-ls
      pkgs.ltex-ls-plus
      pkgs.vtsls
      pkgs.vscode-langservers-extracted
      pkgs.vscode-json-languageserver
      pkgs.package-version-server
    ];
    userSettings = {
      theme = {
        mode = "system";
        dark = "One Dark";
        light = "One Light";
      };
      hour_format = "hour24";
      vim_mode = true;
      load_direnv = "shell_hook";

      lsp = {
        tinymist = {
          settings = {
            exportPdf = "onSave";
            outputPath = "$root/$name";
            preview.background.enabled = true;
          };
          initialization_options = {
            preview.background.enabled = true;
          };
        };
      };
    };
  };
  home.file."Library/Application Support/Gram/extensions/installed" = {
    enable = pkgs.stdenv.hostPlatform.isDarwin;
    source = extensions-dir;
    onChange = ''
      cd "Library/Application Support/Gram/extensions"
      mv index.json index.json.backup
    '';
  };
  xdg.dataFile."gram/extensions/installed" = {
    enable = pkgs.stdenv.hostPlatform.isLinux;
    source = extensions-dir;
    onChange = ''
      cd "${config.xdg.dataHome}/gram/extensions"
      mv index.json index.json.backup
    '';
  };
}
