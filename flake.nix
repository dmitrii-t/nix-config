{
  description = "Neka's macbook flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        pkgs.neovim
        pkgs.yazi
        pkgs.aerospace
        pkgs.wezterm
        pkgs.orbstack
        pkgs.betterdisplay
        pkgs.obsidian
        pkgs.keepassxc
        pkgs.just
	      pkgs.stow
        pkgs.shottr
      ];

      homebrew = {
        enable = true;
        casks = [
           "openmtp"
           "amneziavpn"
           "steam"
           "waterfox"
           "google-drive"
           "telegram-desktop"
           "slack"
           "google-chrome"
           "happ"
           "tunnelblick"
           "jetbrains-toolbox"
           "claude-code@latest"
        ];
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      system.defaults = {
        dock = {
          autohide = true;
          orientation = "right";
          show-recents = false;
        };
        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          _FXSortFoldersFirst = true;
        };
        loginwindow.GuestEnabled = false;
        trackpad = {
          Clicking = true;
          TrackpadPinch = true;
        };
        NSGlobalDomain = {
          "com.apple.mouse.tapBehavior" = 1;
          AppleInterfaceStyle = "Dark";
          KeyRepeat = 2;
          InitialKeyRepeat = 20;
        };
        menuExtraClock.Show24Hour = true;
      };


      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      system.primaryUser = "neka";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#macbook
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "neka";
            };
          }
      ];
    };
  };
}
