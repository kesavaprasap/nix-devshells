# Neovim configured via nixvim
{ pkgs, lib, inputs, system }:

let
  configuredNeovim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
    module = {
      # ------------------------
      # Core options
      # ------------------------
      opts = {
        number = true;
        relativenumber = false;
        expandtab = true;
        shiftwidth = 2;
        tabstop = 2;
        softtabstop = 2;
        smartindent = true;
        autoindent = true;

        termguicolors = true;
        signcolumn = "yes";
        updatetime = 50;

        hlsearch = true;
        incsearch = true;
        ignorecase = true;
        smartcase = true;

        wrap = false;
        cursorline = true;

        splitright = true;
        splitbelow = true;

        completeopt = ["menu" "menuone" "noselect" "noinsert"];

        winblend = 0;
        errorbells = false;

        backspace = ["indent" "eol" "start"];
        iskeyword = "_";
        selection = "inclusive";

        mouse = "a";
        clipboard = "unnamedplus";

        encoding = "utf-8";
        path = "**";
      };

      globals.mapleader = " ";
      globals.maplocalleader = " ";

      # ------------------------
      # Theme
      # ------------------------
      colorschemes.gruvbox = {
        enable = true;
        settings = {
          contrast_dark = "hard";
          italic = {
            strings = false;
            operators = false;
            comments = true;
          };
        };
      };

      # ------------------------
      # Plugins
      # ------------------------
      plugins = {

        # LSP
        lsp = {
          enable = true;
          servers = {
            nil_ls.enable = true;
            rust_analyzer = {
              enable = true;
              installCargo = false;
              installRustc = false;
            };
            clangd.enable = true;
            pyright.enable = true;
          };
        };

        # Completion
        cmp = {
          enable = true;
          autoEnableSources = true;

          settings = {
            mapping.__raw = ''
              cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(),
                ['<C-n>'] = cmp.mapping.select_next_item(),
                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
              })
            '';

            sources = [
              { name = "nvim_lsp"; }
              { name = "luasnip"; }
              { name = "buffer"; }
              { name = "path"; }
            ];
          };
        };

        cmp-nvim-lsp.enable = true;
        cmp-buffer.enable = true;
        cmp-path.enable = true;
        luasnip.enable = true;
        cmp_luasnip.enable = true;

        # Treesitter
        treesitter = {
          enable = true;

          settings = {
            highlight.enable = true;
            indent.enable = true;
          };
        };

        treesitter-context.enable = true;

        # Telescope
        telescope = {
          enable = true;

          keymaps = {
            "<leader>ff" = {
              action = "find_files";
              options.desc = "Find files";
            };
            "<leader>fg" = {
              action = "live_grep";
              options.desc = "Live grep";
            };
            "<leader>fb" = {
              action = "buffers";
              options.desc = "Find buffers";
            };
          };
        };

        # File tree
        nvim-tree = {
          enable = true;

          settings = {
            view = {
              width = 30;
            };
            filters = {
              dotfiles = false;
            };
          };
        };

        # Git
        gitsigns.enable = true;

        # Statusline (FIXED)
        lualine = {
          enable = true;

          settings = {
            options = {
              theme = "gruvbox";
            };
          };
        };

        # QoL
        which-key.enable = true;
        comment.enable = true;
        nvim-autopairs.enable = true;
        indent-blankline.enable = true;

        # Optional (disabled)
        oil.enable = false;

        web-devicons.enable = true;
      };

      # ------------------------
      # Extra Lua
      # ------------------------
      extraConfigLua = ''
        vim.diagnostic.config({
          virtual_text  = true,
          signs         = true,
          underline     = true,
          update_in_insert = false,
          severity_sort = true,
        })
      '';
    };
  };

in {
  meta = {
    name = "editors";
    description = "Neovim IDE with LSP";
    category = "tool";
  };

  packages = [
    configuredNeovim
    pkgs.pyright
  ];
}
