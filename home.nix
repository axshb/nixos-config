{ config, pkgs, ... }:
let
  secrets = import ./vars.nix;
in
{
  home.username = secrets.username;
  home.homeDirectory = "/home/${secrets.username}";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Apps
    brave vscode vesktop spotify mullvad-vpn kdePackages.okular
    qimgv polkit_gnome
    # CLI
    kitty micro yazi btop fastfetch
    # Desktop
    waybar mako swaybg hyprshot wl-clipboard
    kanshi rofi 
    # Gaming
    protonup-qt xivlauncher fflogs 
    # ML 
    koboldcpp 
    # Cosmic
    cosmic-settings cosmic-settings-daemon cosmic-osd cosmic-randr
  ];

  home.file = {
    ".config/waybar".source = ./dotfiles/waybar;
    ".config/labwc".source = ./dotfiles/labwc;
    ".config/kitty".source = ./dotfiles/kitty;
    ".config/yazi".source = ./dotfiles/yazi;
    ".config/btop".source = ./dotfiles/btop;
    ".config/kanshi".source = ./dotfiles/kanshi;
    ".config/mako".source = ./dotfiles/mako;
    ".config/rofi".source = ./dotfiles/rofi;
    ".local/share/themes/Custom-Theme".source = ./dotfiles/themes/Custom-Theme; # labwc theme
    ".config/fastfetch".source = ./dotfiles/fastfetch;
    ".config/hypr".source = ./dotfiles/hypr;
  };

  home.stateVersion = "24.11";
}
