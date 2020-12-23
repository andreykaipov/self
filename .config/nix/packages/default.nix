{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # https://search.nixos.org/packages
  #
  environment.systemPackages = with pkgs; [
    # The *.app kind of applications
    iterm2
    (callPackage ./discord {})
    (callPackage ./spotify {})
    (callPackage ./rectangle {})
    (callPackage ./1password {})
    (callPackage ./docker {})
    (callPackage ./barrier {})

    # The other stuff
    tmux
    coreutils
    shellcheck
    jq
    yq
    upx
    tre-command
    tree
    gifsicle
    (callPackage ./neovim {})
    (callPackage ./dircolors.hex {})
  ];

  # Copy applications installed via Nix to ~ so Spotlight can index them
  system.activationScripts.applications.text = pkgs.lib.mkForce (''
    IFS=$'\n'

    hashApp() {
        path="$1/Contents/MacOS"; shift

        for bin in $(find "$path" -perm +111 -type f -maxdepth 1 2>/dev/null); do
            md5sum "$bin" | cut -b-32
        done | md5sum | cut -b-32
    }

    mkdir -p ~/Applications/Nix\ Apps

    for app in $(find ${config.system.build.applications}/Applications -maxdepth 1 -type l); do
        name="$(basename "$app")"

        src="$(/usr/bin/stat -f%Y "$app")"
        dst="$HOME/Applications/Nix Apps/$name"

        hash1="$(hashApp "$src")"
        hash2="$(hashApp "$dst")"

        if [ "$hash1" != "$hash2" ]; then
            echo "Current hash of '$name' differs than the Nix store's. Overwriting..."
            cp -R "$src" ~/Applications/Nix\ Apps
            echo "Done"
        fi
    done
  '');

  system.activationScripts.postActivation.text = ''
    nvim +PlugInstall +qa
  '';
}
