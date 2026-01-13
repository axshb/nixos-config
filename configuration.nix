{ config, pkgs, ... }:
let
  secrets = import ./vars.nix;
in
{
  imports = [ ./hardware-configuration.nix ];

  # ============================================================================
  # SYSTEM CORE
  # ============================================================================
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "nvidia_drm.fbdev=1"
      # --- trying to fix wifi connectivity under load ---
      "iwlwifi.swcrypto=1" # unhandled alg 0x707 and 0x703 error: move encryption from hardware to software
      # wifi power management settings
      "iwlwifi.power_save=0"
      "iwlmvm.power_scheme=1" # (1 = acive/performance)
      # turn off pcie power state management
      "pcie_aspm=off"
    ];
  };
  # nm power management; also to fix unstable wifi under load.
  networking.networkmanager.wifi.powersave = false;

  time.timeZone = secrets.timezone;
  i18n.defaultLocale = secrets.locale;
  nixpkgs.config.allowUnfree = true;
  hardware.uinput.enable = true;

  # ============================================================================
  # NETWORKING & SECURITY
  # ============================================================================
  networking = {
    hostName = secrets.hostname;
    networkmanager.enable = true;
    networkmanager.dns = "none";
    enableIPv6 = false;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };
  services.mullvad-vpn.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  # ============================================================================
  # HARDWARE & GRAPHICS (NVIDIA 4070 SUPER)
  # ============================================================================
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    bluetooth.enable = true;
    enableAllFirmware = true;
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  services.blueman.enable = true;
  services.fwupd.enable = true;

  # ============================================================================
  # SYSTEM SERVICES
  # ============================================================================
  services.udisks2.enable = true;
  security.pam.services.${secrets.username}.enableGnomeKeyring = true;

  # ============================================================================
  # DESKTOP ENVIRONMENT & GUI
  # ============================================================================
  xdg.portal = {
    enable = true;
    wlr.enable = true; 
    extraPortals = [ 
      pkgs.xdg-desktop-portal-cosmic 
      pkgs.xdg-desktop-portal-gtk 
    ];
    config = {
      common = {
        default = [ "cosmic" "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      };
    };
  };
  
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  fonts.packages = with pkgs; [
    noto-fonts
    jetbrains-mono
    noto-fonts-color-emoji
  ];

  stylix = {
    enable = true;
    image = ./preview.png;
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/atelier-savanna.yaml";
    base16Scheme = {
      base00 = "191919"; # Background
      base01 = "242424"; # Lighter Background
      base02 = "353535"; # Selection Background
      base03 = "464646"; # Comments
      base04 = "5e5e5e"; # Dark Foreground
      base05 = "9d9d9d"; # Default Foreground
      base06 = "b1b1b1"; # Light Foreground
      base07 = "eeeeee"; # Lightest Foreground
      base08 = "e35535"; # Red
      base09 = "e8851a"; # Orange
      base0A = "90a020"; # Yellow
      base0B = "2c9431"; # Green
      base0C = "3da69e"; # Cyan
      base0D = "4180d1"; # Blue
      base0E = "985ec9"; # Magenta
      base0F = "915042"; # Brown
    };
    targets.gtk.enable = true; 
    targets.chromium.enable = false;
    autoEnable = true;
    cursor = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-dark";
      size = 24;
    };
  };

  # ============================================================================
  # REMOTE DESKTOP
  # ============================================================================
  # replacing wayvnc for sunshine
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", SYMLINK+="uinput"
  '';

  # ============================================================================
  # GAMING
  # ============================================================================
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # ============================================================================
  # STORAGE & DRIVES
  # ============================================================================
  fileSystems."${secrets.workspace_path}" = {
    device = "/dev/disk/by-label/${secrets.workspace_label}";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  fileSystems."${secrets.games_path}" = {
    device = "/dev/disk/by-label/${secrets.games_label}";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  # ============================================================================
  # USER ACCOUNT & PACKAGES
  # ============================================================================
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = "fastfetch";
  };
  users.users.${secrets.username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" "input" "gamemode" "uinput" "render" "storage" ];
  };
  environment.systemPackages = with pkgs; [
    git
    wtype
    # The Core Suite
    cosmic-files
    cosmic-settings
    cosmic-settings-daemon
    cosmic-osd
    cosmic-randr
  ];
  system.stateVersion = "24.11";
}
