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
  services.fwupd.enable = true;

  # ============================================================================
  # SYSTEM SERVICES
  # ============================================================================
  services.udisks2.enable = true;
  security.pam.services.${secrets.username}.enableGnomeKeyring = true;

  # ============================================================================
  # DESKTOP ENVIRONMENT & GUI
  # ============================================================================
  programs.hyprland = {
    enable = true;
    withUWSM = true; 
    xwayland.enable = true;
  };
  
  xdg.portal = {
    enable = true;
    wlr.enable = true; 
    extraPortals = [ 
      pkgs.xdg-desktop-portal-cosmic
      pkgs.xdg-desktop-portal-hyprland 
      pkgs.xdg-desktop-portal-gtk 
    ];
    config = {
      common = {
        default = [ "cosmic" "gnome" "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
      };
    };
  };
  
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  fonts.packages = with pkgs; [
    noto-fonts
    jetbrains-mono
    noto-fonts-color-emoji
  ];

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
  ];
  system.stateVersion = "24.11";
}
