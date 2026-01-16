{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Theme
    colorschemes.gruvbox-material = {
      enable = true;
      settings = {
        background = "hard";
        foreground = "material";
      };
    };
    opts.background = "dark";

    opts = {
      number = true;         
      relativenumber = true; 
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      smartindent = true;
      cursorline = true;
      termguicolors = true;
      clipboard = "unnamedplus";
    };

    plugins = {
      lualine.enable = true;
      bufferline.enable = true;
      neo-tree.enable = true;
      web-devicons.enable = true;
      which-key.enable = true;
      comment.enable = true;
      telescope.enable = true;
      treesitter.enable = true;

      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;
          gopls.enable = true;
          pyright.enable = true;
          ts_ls.enable = true;
          clangd.enable = true;
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [{ name = "nvim_lsp"; } { name = "path"; } { name = "buffer"; }];
          mapping = {
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping.select_next_item()";
            "<S-Tab>" = "cmp.mapping.select_prev_item()";
          };
        };
      };
    };

    globals.mapleader = " ";
    keymaps = [
      { mode = "n"; key = "<leader>e"; action = ":Neotree toggle<CR>"; }
      { mode = "n"; key = "<leader>ff"; action = ":Telescope find_files<CR>"; }
      { mode = "n"; key = "<Tab>"; action = ":bnext<CR>"; }
      { mode = "n"; key = "<S-Tab>"; action = ":bprev<CR>"; }
    ];
  };
}
