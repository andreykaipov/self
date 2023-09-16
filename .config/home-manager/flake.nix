{
  description = "Andrey's Home Manager config";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-23.05";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    devenv.url = "github:cachix/devenv/latest"; # don't follow 
  };

  outputs =
    inputs @ { self
    , nixos
    , nixos-unstable
    , nixpkgs-unstable
    , home-manager
    , devenv
    , ...
    }:
    let
      username = "andrey";

      homeConfig = system: extraModules: hostName:
        home-manager.lib.homeManagerConfiguration rec {
          pkgs = nixpkgs-unstable.legacyPackages.${system}; # or just reimport again

          lib = nixos.lib.extend (libself: super: {
            my = import ./lib.nix {
              inherit system pkgs;
              lib = libself;
              flake = self;
            };
          });

          modules = [
            {
              # alternatively, we can set these in `import nixpkgs { ... }`
              # instead of using legacyPackages above
              nixpkgs.config.allowUnfreePredicate = (pkg: true); # https://github.com/nix-community/home-manager/issues/2942
              nixpkgs.overlays = lib.my.overlays;
            }
            {
              home.username = username;
              home.homeDirectory = lib.my.homedir username;
              home.stateVersion = "22.11";
            }
            ./home.nix
          ]
          ++ extraModules;

          extraSpecialArgs = {
            pkgs-stable = import nixos { inherit system; config.allowUnfree = true; };
            devenv = devenv.packages.${system}.devenv;
          };
        };
    in
    {
      homeConfigurations = builtins.mapAttrs (hostname: configurer: configurer hostname) {
        dustbox = homeConfig "x86_64-linux" [ ./wsl.nix ];
        smart-toaster = homeConfig "aarch64-darwin " [ ./macos.nix ];
      };
    };
}

