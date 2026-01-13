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
    brave vscode vesktop spotify qimgv mullvad-vpn zathura
    polkit_gnome
    # CLI
    kitty micro yazi btop fastfetch
    # Desktop
    waybar mako swaybg hyprshot wl-clipboard
    wlr-randr networkmanagerapplet kanshi rofi 
    labwc pavucontrol wdisplays
    # Gaming
    protonup-qt xivlauncher fflogs 
    # ML 
    koboldcpp 
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
    ".local/share/themes/Atelier-Savanna".source = ./dotfiles/themes/Atelier-Savanna; # labwc theme
    ".config/fastfetch".source = ./dotfiles/fastfetch;
  };

  home.stateVersion = "24.11";
}
