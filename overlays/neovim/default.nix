# There's no section on overlays, but it's sorta similar
#
# https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/vim.section.md
# https://nixos.wiki/wiki/Vim#Custom_setup_without_using_Home_Manager
#
#neovim github Plugins refer to the repo name only, i.e. LnL7/vim-nix is just vim-nix. Fully
# qualified repos with author names can be found at:
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/misc/vim-plugins/generated.nix

#let
#  unstable = import <nixpkgs> { };
#in
self: super: {
  neovim-unwrapped =
    super.neovim-unwrapped.overrideAttrs (oldAttrs: rec {
      pname = oldAttrs.pname;
      version = "0.9.1";

      src = super.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "v${version}";
        sha256 = "sha256-G51qD7GklEn0JrneKSSqDDx0Odi7W2FjdQc0ZDE9ZK4=";
      };

      patches = oldAttrs.patches ++ [
        ./relative-numbers.patch
      ];
    });

  neovim =
    super.neovim.override (old: rec {
      viAlias = true;
      vimAlias = true;
    });
}
