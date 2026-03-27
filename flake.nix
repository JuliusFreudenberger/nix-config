{
  description = "NixOS configuration of Julius Freudenberger";

  nixConfig = {
    extra-substituters = [
      "https://cache.saumon.network/proxmox-nixos"
    ];
    extra-trusted-public-keys = [
      "proxmox-nixos:D9RYSWpQQC/msZUWphOY2I5RLH5Dd6yQcaHIuug7dWM="
    ];
  };

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lazy-apps = {
      url = "sourcehut:~rycee/lazy-apps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
      };
    };
    secrets = {
      url = "git+ssh://git@git.jfreudenberger.de/JuliusFreudenberger/nix-private.git";
      flake = false;
    };
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixos-hardware,
    home-manager,
    auto-cpufreq,
    proxmox-nixos,
    agenix,
    disko,
    systems,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib;
    eachSystem = lib.genAttrs (import systems);
    forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
    pkgsFor = eachSystem (
      system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
    );
  in {

    overlays = import ./overlays {inherit inputs outputs;};
    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});

    nixosConfigurations = {
      julius-framework = let
        username = "julius";
      in
      nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        specialArgs = {
	  inherit inputs outputs username;
        };

        modules = [
          nixos-hardware.nixosModules.framework-11th-gen-intel
          auto-cpufreq.nixosModules.default
          ./hosts/julius-framework
          ./users/julius/nixos.nix

          home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.extraSpecialArgs = inputs // specialArgs;
              home-manager.users.${username} = import ./users/${username}/home.nix;
            }
        ];
      };

      backup-raspberrypi = nixpkgs.lib.nixosSystem rec {
        system = "aarch64";

        specialArgs = {
          inherit inputs outputs;
        };

        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          ./hosts/backup-raspberrypi
        ];
      };

      busch = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        specialArgs = {
          inherit inputs outputs;
        };

        modules = [
          ./hosts/busch
          disko.nixosModules.disko
          proxmox-nixos.nixosModules.proxmox-ve

          ({...}: {
            nixpkgs.overlays = [
              proxmox-nixos.overlays.${system}
            ];
          })
        ];
      };

      srv01-hf = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        specialArgs = {
          inherit inputs outputs;
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };

        modules = [
          disko.nixosModules.disko
          agenix.nixosModules.default
          ./hosts/srv01.hf
        ];
      };

    };

    homeConfigurations = {
      jufr2 = let
        username = "jufr2";
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
      in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit username;
        };

        modules = [
          home/core.nix

          home/targets/genericLinux.nix

          modules/nix.nix
          home/neovim/default.nix
          home/zsh/default.nix
          home/cli.nix
          home/gui.nix
          home/java-dev.nix

          home/direnv/default.nix
        ];

      };
    };

    devShells = eachSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        java11-maven = pkgs.mkShell { packages = with pkgs; [ maven jdk11 ]; };
        java17-maven = pkgs.mkShell { packages = with pkgs; [ maven jdk17 ]; };
        java21-maven = pkgs.mkShell { packages = with pkgs; [ maven jdk21 ]; };
        texlive-with-pygments = pkgs.mkShell { packages = with pkgs; [ texliveFull python3Packages.pygments ]; };
        php8 = pkgs.mkShell { packages = with pkgs; [
          (php82.buildEnv {
            extensions = ({ enabled, all }: enabled ++ (with all; [
              xdebug
            ]));
            extraConfig = ''
              xdebug.mode=debug
            '';
          })
          php82Packages.composer
        ];};
      }
    );

  };
}
