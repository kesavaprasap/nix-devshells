# Neovim configured via nixvim
# LSP servers (rust-analyzer, clangd, nil, basedpyright) are configured but NOT
# bundled — they come from language modules in the shell's PATH.
# basedpyright is the exception: included here for standalone Python editing.
{
  pkgs,
  lib,
  inputs,
  system,
}:
let
  configuredNeovim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
    module = {
      # ── Editor options ────────────────────────────────────────────────────
      opts = {
        number = true;
        relativenumber = true;
        expandtab = true;
        shiftwidth = 2;
        tabstop = 2;
        smartindent = true;
        termguicolors = true;
        scrolloff = 8;
        signcolumn = "yes";
        updatetime = 50;
        hlsearch = false;
        incsearch = true;
        ignorecase = true;
        smartcase = true;
        wrap = false;
        cursorline = true;
        splitright = true;
        splitbelow = true;
      };

      globals.mapleader = " ";

      # ── Colorscheme ───────────────────────────────────────────────────────
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

      # ── Plugins ───────────────────────────────────────────────────────────
      plugins = {

        # LSP — package = null means nixvim configures lspconfig but does NOT
        # bundle the server binary; each server must be in the shell's PATH
        # (provided by the respective language module).
        lsp = {
          enable = true;
          servers = {
            nil_ls = {
              enable = true;
              package = null; # provided by modules/tools/nix-tools.nix (nil)
            };
            rust_analyzer = {
              enable = true;
              installCargo = false;
              installRustc = false;
              package = null; # provided by modules/languages/rust.nix (rustToolchain)
            };
            clangd = {
              enable = true;
              package = null; # provided by modules/languages/cpp.nix (clang-tools)
            };
            basedpyright = {
              enable = true;
              package = null; # provided below in module packages + python.nix
            };
          };
        };

        # Completion
        cmp = {
          enable = true;
          autoEnableSources = true;
          settings = {
            mapping.__raw = ''
              cmp.mapping.preset.insert({
                ['<C-p>']     = cmp.mapping.select_prev_item(),
                ['<C-n>']     = cmp.mapping.select_next_item(),
                ['<C-d>']     = cmp.mapping.scroll_docs(-4),
                ['<C-f>']     = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<CR>']      = cmp.mapping.confirm({ select = true }),
                ['<Tab>']     = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  else
                    fallback()
                  end
                end, { 'i', 's' }),
              })
            '';
            sources = [
              {name = "nvim_lsp";}
              {name = "luasnip";}
              {name = "buffer";}
              {name = "path";}
            ];
          };
        };
        cmp-nvim-lsp.enable = true;
        cmp-buffer.enable = true;
        cmp-path.enable = true;
        luasnip.enable = true;
        cmp_luasnip.enable = true;

        # Syntax highlighting and indentation
        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            indent.enable = true;
          };
        };
        treesitter-context.enable = true;

        # Fuzzy finder
        telescope = {
          enable = true;
          keymaps = {
            "<leader>ff" = {action = "find_files"; options.desc = "Find files";};
            "<leader>fg" = {action = "live_grep"; options.desc = "Live grep";};
            "<leader>fb" = {action = "buffers"; options.desc = "Find buffers";};
            "<leader>fh" = {action = "help_tags"; options.desc = "Help tags";};
            "<leader>fr" = {action = "oldfiles"; options.desc = "Recent files";};
            "<leader>fd" = {action = "diagnostics"; options.desc = "Diagnostics";};
          };
        };

        # File explorer
        oil = {
          enable = true;
          settings = {
            default_file_explorer = true;
            view_options.show_hidden = true;
          };
        };

        # Git decorations
        gitsigns = {
          enable = true;
          settings.signs = {
            add.text = "+";
            change.text = "~";
            delete.text = "_";
          };
        };

        # Status line
        lualine = {
          enable = true;
          settings.options.theme = "gruvbox";
        };

        # Keybinding hints popup
        which-key.enable = true;

        # gc / gb to comment lines/blocks
        comment.enable = true;

        # Auto-close brackets and quotes
        nvim-autopairs.enable = true;

        # Indent guides
        indent-blankline.enable = true;
      };

      # ── Diagnostic display ────────────────────────────────────────────────
      extraConfigLua = ''
        vim.diagnostic.config({
          virtual_text  = true,
          signs         = true,
          underline     = true,
          update_in_insert = false,
          severity_sort = true,
        })
      '';

      # ── Keymaps ───────────────────────────────────────────────────────────
      keymaps = [
        # File explorer
        {mode = "n"; key = "-"; action = "<CMD>Oil<CR>"; options.desc = "Open parent directory";}

        # LSP actions
        {mode = "n"; key = "gd"; action.__raw = "vim.lsp.buf.definition"; options.desc = "Go to definition";}
        {mode = "n"; key = "gD"; action.__raw = "vim.lsp.buf.declaration"; options.desc = "Go to declaration";}
        {mode = "n"; key = "gi"; action.__raw = "vim.lsp.buf.implementation"; options.desc = "Go to implementation";}
        {mode = "n"; key = "gr"; action.__raw = "vim.lsp.buf.references"; options.desc = "Find references";}
        {mode = "n"; key = "K"; action.__raw = "vim.lsp.buf.hover"; options.desc = "Hover documentation";}
        {mode = "n"; key = "<leader>ca"; action.__raw = "vim.lsp.buf.code_action"; options.desc = "Code action";}
        {mode = "n"; key = "<leader>rn"; action.__raw = "vim.lsp.buf.rename"; options.desc = "Rename symbol";}
        {mode = "n"; key = "<leader>f"; action.__raw = "function() vim.lsp.buf.format({ async = true }) end"; options.desc = "Format buffer";}

        # Diagnostics
        {mode = "n"; key = "[d"; action.__raw = "vim.diagnostic.goto_prev"; options.desc = "Prev diagnostic";}
        {mode = "n"; key = "]d"; action.__raw = "vim.diagnostic.goto_next"; options.desc = "Next diagnostic";}
        {mode = "n"; key = "<leader>e"; action.__raw = "vim.diagnostic.open_float"; options.desc = "Diagnostic float";}
        {mode = "n"; key = "<leader>q"; action.__raw = "vim.diagnostic.setloclist"; options.desc = "Diagnostic list";}

        # Window navigation
        {mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Move to left split";}
        {mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Move to lower split";}
        {mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Move to upper split";}
        {mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Move to right split";}

        # Buffer management
        {mode = "n"; key = "<leader>bd"; action = "<CMD>bd<CR>"; options.desc = "Delete buffer";}
        {mode = "n"; key = "<leader>bn"; action = "<CMD>bnext<CR>"; options.desc = "Next buffer";}
        {mode = "n"; key = "<leader>bp"; action = "<CMD>bprev<CR>"; options.desc = "Prev buffer";}

        # Clear search highlight
        {mode = "n"; key = "<Esc>"; action = "<CMD>nohlsearch<CR>";}
      ];
    };
  };
in {
  meta = {
    name = "editors";
    description = "Neovim IDE with LSP, treesitter, telescope, and gruvbox";
    category = "tool";
  };

  # configuredNeovim wraps the neovim binary with all plugin paths baked in.
  # basedpyright is included here so Python LSP works even without the python
  # language module (it is also added by python.nix to avoid duplication issues).
  packages = [
    configuredNeovim
    pkgs.basedpyright
  ];

  shellHook = ''
    echo "  Neovim (LSP + plugins) ready — leader: <Space>"
    echo "    <Space>ff  find files    <Space>fg  live grep"
    echo "    <Space>fb  buffers       -          file explorer"
    echo "    LSPs: nil · rust-analyzer · clangd · basedpyright"
  '';
}
