{ config, pkgs, ... }:
let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in
{

  # Hardware
  imports = [ ./hardware-configuration.nix ];

  # Load unstable packages
  nixpkgs.config = {
    packageOverrides = pkgs: with pkgs; {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # System settings
  system.stateVersion = "23.11";

  # Internationalization
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # X11 Configuration
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };
  services.printing.enable = true;

  # Sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Users
  users.users.violet = {
    isNormalUser = true;
    description = "Violet Iapalucci";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    discord
    firefox
    git
    gcc
    jetbrains.idea-community
    libreoffice-qt
    lua
    neofetch
    neovim
    nodejs_21
    onefetch
    rocmPackages.llvm.clang
    rustup
    ueberzugpp
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
        github.copilot
        gruntfuggly.todo-tree
        pkief.material-icon-theme
        redhat.java
        rust-lang.rust-analyzer
        serayuzgur.crates
        tamasfe.even-better-toml
        usernamehw.errorlens
        vscodevim.vim
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "one-midnight";
          publisher = "violetiapalucci";
          version = "1.0.0";
          sha256 = "sha256-mx3hz2pRwL0cUDGnRy9eER/+SR7KXc8et2RcW//Ct6Q=";
        }
      ];
    })
    wezterm
  ];

  programs.java.enable = true;
  programs.java.package = pkgs.jdk21;

  fonts.packages = with pkgs; [
    fira-code
  ];
}
