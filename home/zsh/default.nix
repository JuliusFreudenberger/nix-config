{config, pkgs, pkgs-unstable, ...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";

    shellAliases = {
      Gst = "git status";
      Gco = "git checkout";
      Gd = "git diff";
      Gds = "git diff --staged";
      Gc = "git commit";
    };

    history.size = 10000;
    history.path = "$HOME/.zsh_history";

    plugins = [

    ];

    initExtra = ''
      setopt promptsubst
      export PROMPT='%F{12}[%f%F{10}%n%f%F{12}@%f%F{white}%m%f%F{12}]%f%F{white}:%f %F{white}%~%f%F{12}>%b$(${pkgs-unstable.gitprompt-rs}/bin/gitprompt-rs)%f%F{10}%(!.#.$)%f '
      unsetopt beep
      bindkey '^R' history-incremental-search-backward
    '';

    initExtraBeforeCompInit = "zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*'";
  };
}
