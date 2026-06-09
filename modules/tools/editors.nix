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

        # Floating terminal (VTE-compatible)
        toggleterm = {
          enable = true;
          settings = {
            open_mapping = null;
            direction = "float";
            float_opts = {
              border = "curved";
              winblend = 0;
            };
            # xterm-256color keeps VTE from choking on unsupported sequences
            env = { TERM = "xterm-256color"; };
            start_in_insert = true;
            close_on_exit = true;
          };
        };

        # Key hints with group labels
        which-key = {
          enable = true;
          settings.spec = [
            { __unkeyed-1 = "<leader>f"; group = "find/format"; }
            { __unkeyed-1 = "<leader>b"; group = "buffer"; }
            { __unkeyed-1 = "<leader>n"; group = "tree"; }
            { __unkeyed-1 = "<leader>c"; group = "code"; }
            { __unkeyed-1 = "<leader>r"; group = "rename"; }
          ];
        };
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

        -- VTE terminals (GNOME Terminal, Tilix) support truecolor but may not
        -- set $COLORTERM; force termguicolors on when detected.
        if vim.env.VTE_VERSION then
          vim.opt.termguicolors = true
        end

        -- Restore cursor position on file open
        vim.api.nvim_create_autocmd("BufReadPost", {
          callback = function()
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
              vim.api.nvim_win_set_cursor(0, mark)
            end
          end,
        })

        -- Clean terminal buffers (no line numbers / sign column)
        vim.api.nvim_create_autocmd("TermOpen", {
          callback = function()
            vim.opt_local.number         = false
            vim.opt_local.relativenumber = false
            vim.opt_local.signcolumn     = "no"
          end,
        })
      '';

      keymaps = [
        # Terminal — works from both normal and terminal mode
        { mode = ["n" "t"]; key = "<leader>t"; action = "<CMD>ToggleTerm<CR>"; options.desc = "Toggle terminal"; }
        { mode = "t"; key = "<Esc>"; action = "<C-\\><C-n>"; options.desc = "Exit terminal mode"; }

        # File tree
        { mode = "n"; key = "<leader>nt"; action = "<CMD>NvimTreeToggle<CR>"; options.desc = "Toggle file tree"; }

        # LSP
        { mode = "n"; key = "gd"; action.__raw = "vim.lsp.buf.definition"; options.desc = "Go to definition"; }
        { mode = "n"; key = "gD"; action.__raw = "vim.lsp.buf.declaration"; options.desc = "Go to declaration"; }
        { mode = "n"; key = "gi"; action.__raw = "vim.lsp.buf.implementation"; options.desc = "Go to implementation"; }
        { mode = "n"; key = "gr"; action.__raw = "vim.lsp.buf.references"; options.desc = "Find references"; }
        { mode = "n"; key = "K";  action.__raw = "vim.lsp.buf.hover"; options.desc = "Hover docs"; }
        { mode = "n"; key = "<leader>ca"; action.__raw = "vim.lsp.buf.code_action"; options.desc = "Code action"; }
        { mode = "n"; key = "<leader>rn"; action.__raw = "vim.lsp.buf.rename"; options.desc = "Rename symbol"; }
        { mode = "n"; key = "<leader>f";  action.__raw = "function() vim.lsp.buf.format({ async = true }) end"; options.desc = "Format buffer"; }

        # Diagnostics
        { mode = "n"; key = "[d"; action.__raw = "vim.diagnostic.goto_prev"; options.desc = "Prev diagnostic"; }
        { mode = "n"; key = "]d"; action.__raw = "vim.diagnostic.goto_next"; options.desc = "Next diagnostic"; }
        { mode = "n"; key = "<leader>e"; action.__raw = "vim.diagnostic.open_float"; options.desc = "Diagnostic float"; }
        { mode = "n"; key = "<leader>q"; action.__raw = "vim.diagnostic.setloclist"; options.desc = "Diagnostic list"; }

        # Window navigation
        { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Move left"; }
        { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Move down"; }
        { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Move up"; }
        { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Move right"; }

        # Buffer management
        { mode = "n"; key = "<leader>bd"; action = "<CMD>bd<CR>"; options.desc = "Delete buffer"; }
        { mode = "n"; key = "<leader>bn"; action = "<CMD>bnext<CR>"; options.desc = "Next buffer"; }
        { mode = "n"; key = "<leader>bp"; action = "<CMD>bprev<CR>"; options.desc = "Prev buffer"; }

        # Editing
        { mode = "n"; key = "<Esc>";     action = "<CMD>nohlsearch<CR>"; }
        { mode = "x"; key = "<leader>p"; action = "\"_dP"; options.desc = "Paste without yanking"; }
        { mode = ["n" "v"]; key = "<leader>x"; action = "\"_d"; options.desc = "Delete without yanking"; }
        { mode = "v"; key = "<";  action = "<gv"; options.desc = "Indent left and reselect"; }
        { mode = "v"; key = ">";  action = ">gv"; options.desc = "Indent right and reselect"; }
        { mode = "n"; key = "<A-j>"; action = ":m .+1<CR>=="; options.desc = "Move line down"; }
        { mode = "n"; key = "<A-k>"; action = ":m .-2<CR>=="; options.desc = "Move line up"; }
        { mode = "v"; key = "<A-j>"; action = ":m '>+1<CR>gv=gv"; options.desc = "Move selection down"; }
        { mode = "v"; key = "<A-k>"; action = ":m '<-2<CR>gv=gv"; options.desc = "Move selection up"; }
      ];
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
