{
  description = "Andrey's Home Manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs-master.url = "github:nixos/nixpkgs/master";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    devenv.url = "github:cachix/devenv/latest"; # don't follow

    neovim-nightly.url = "github:neovim/neovim?dir=contrib"; #" #&rev=eb151a9730f0000ff46e0b3467e29bb9f02ae362";
    neovim-nightly.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # zsh plugins
    zsh-powerlevel10k.url = "github:romkatv/powerlevel10k";
    zsh-powerlevel10k.flake = false;
    zsh-completions.url = "github:zsh-users/zsh-completions";
    zsh-completions.flake = false;
    zsh-fzf-tab.url = "github:Aloxaf/fzf-tab";
    zsh-fzf-tab.flake = false;
    zsh-fzf-tab-source.url = "github:Freed-Wu/fzf-tab-source";
    zsh-fzf-tab-source.flake = false;
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , nixpkgs-unstable
      # , nixpkgs-master
    , home-manager
    , neovim-nightly
    , devenv
    , ...
    }:
    let
      # lib = nixpkgs-unstable.lib;
      homeConfig = system: hostname:
        let
          pkgs = nixpkgs-unstable.legacyPackages.${system};
          lib = nixpkgs.lib.extend (libself: super: {
            my = import ./lib {
              inherit system pkgs;
              lib = libself;
              flake = self;
            };
          });
          cfg = import ./hosts/${hostname}.nix { inherit lib; };
          username = cfg.username;
          homedir = lib.attrsets.attrByPath [ "homedir" ] "" cfg;
          extraModules = cfg.extraModules;
        in
        home-manager.lib.homeManagerConfiguration
          rec {
            inherit lib pkgs;

            # pkgs = import <nixpkgs> { }; # alternative to above line, but this is impure

            modules = [
              {
                # alternatively, we can set these in `import nixpkgs { ... }` instead of using legacyPackages above
                nixpkgs.config.allowUnfreePredicate = (pkg: true); # https://github.com/nix-community/home-manager/issues/2942
                nixpkgs.overlays = lib.my.overlays ++ [
                  (final: prev: {
                    neovim-nightly = neovim-nightly.packages.${prev.system}.neovim;
                  })
                ];
              }
              {
                home.username = username;
                home.homeDirectory = if homedir != "" then homedir else lib.my.homedir username;
                home.stateVersion = "22.11";
              }
              ./home
            ]
            ++ extraModules;

            extraSpecialArgs = {
              inherit inputs;
              pkgs-stable = import nixpkgs { inherit system; config.allowUnfree = true; };
              devenv = devenv.packages.${system}.devenv;
              homeConfig = cfg;
            };
          };
    in
    {
      homeConfigurations = builtins.mapAttrs (hostname: configurer: configurer hostname) {
        dustbox = homeConfig "x86_64-linux";
        # smart-toaster = homeConfig "x86_64-darwin"; # this is an m1 but aarch64-darwin doesn't work?
        smart-toaster = homeConfig "aarch64-darwin";
      };
    };
}
