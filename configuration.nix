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
    # 3. disable wifi active state power management
    # 4. disable wifi 6
    # 4. turn off power saving on nm
    # all to try to stabilize wifi connectivity under load
    kernelParams = [ "nvidia_drm.fbdev=1" "pcie_aspm=off" "iwlwifi.disable_11ax=1" "iwlwifi.power_save=0" ];
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

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
    };
  };

  # ============================================================================
  # DESKTOP ENVIRONMENT & GUI
  # ============================================================================
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
     ];
    config.common.default = [ "wlr" "gtk" ];
    config.labwc.default = [ "wlr" "gtk" ];
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
