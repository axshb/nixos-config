{ config, pkgs, ... }:
let
  secrets = import ./vars.nix;
  dotfilesPath = "/home/${secrets.username}/nixos-config/dotfiles";
  mkLink = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${path}";  
in
{
  home.username = secrets.username;
  home.homeDirectory = "/home/${secrets.username}";

  imports = [ ./nixvim.nix ];

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # Apps
    brave vscode vesktop spotify mullvad-vpn kdePackages.okular
    qimgv polkit_gnome
    # CLI
    kitty yazi btop fastfetch helix
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
    ".config/waybar".source = mkLink "waybar";
    ".config/labwc".source = mkLink "labwc";
    ".config/kitty".source = mkLink "kitty";
    ".config/yazi".source = mkLink "yazi";
    ".config/btop".source = mkLink "btop";
    ".config/kanshi".source = mkLink "kanshi";
    ".config/mako".source = mkLink "mako";
    ".config/rofi".source = mkLink "rofi";
    ".local/share/themes/Custom-Theme".source = mkLink "themes/Custom-Theme";
    ".config/fastfetch".source = mkLink "fastfetch";
    ".config/hypr".source = mkLink "hypr";
    ".config/niri".source = mkLink "niri";
    ".config/helix".source = mkLink "helix";
  };

  home.stateVersion = "24.11";
}
