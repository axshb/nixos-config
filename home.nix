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
    brave vscode vesktop spotify qimgv mullvad-vpn zed-editor zathura
    polkit_gnome nwg-look libnotify
    # CLI
    kitty micro yazi btop fastfetch
    # Desktop
    labwc waybar mako swaybg hyprshot wl-clipboard
    wlr-randr networkmanagerapplet kanshi rofi
    # Gaming / ML / Themes
    protonup-qt xivlauncher fflogs koboldcpp papirus-icon-theme kanagawa-gtk-theme
  ];

  home.file = {
    ".config/mako/config".source = ./dotfiles/mako/config;
    ".config/waybar".source = ./dotfiles/waybar;
    ".config/labwc".source = ./dotfiles/labwc;
    ".config/kitty".source = ./dotfiles/kitty;
    ".config/yazi".source = ./dotfiles/yazi;
    ".config/btop".source = ./dotfiles/btop;
    ".config/kanshi".source = ./dotfiles/kanshi;
    ".config/mako".source = ./dotfiles/mako;
    ".config/rofi".source = ./dotfiles/rofi;
    ".local/share/themes".source = ./dotfiles/themes;
    ".config/fastfetch".source = ./dotfiles/fastfetch;
  };

  home.stateVersion = "24.11";
}
