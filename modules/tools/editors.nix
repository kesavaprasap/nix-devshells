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
        relativenumber = false;
        expandtab = true;
        shiftwidth = 2;
        tabstop = 2;
        smartindent = true;
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
        softtabstop = 2;
        autoindent = true;
        completeopt = ["menu" "menuone" "noselect" "noinsert"];
        # pumheight = 10;
        winblend = 0;
        errorbells = false;
        backspace = ["indent" "eol" "start"];
        iskeyword = "_";
        selection = "inclusive";
        mouse = "a";
        clipboard = "unnamedplus";
        modifiable = true;
        encoding = "utf-8";
        path = "**";


      };

      globals.mapleader = " ";
      globals.maplocalleader = " ";

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

        # File explorer (buffer-based)
        oil = {
          enable = false;
          settings = {
            default_file_explorer = true;
            view_options.show_hidden = true;
          };
        };

        # File tree sidebar
        nvim-tree = {
          enable = true;
          settings = {
            view.width = 30;
            renderer.group_empty = true;
            filters.dotfiles = false;
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
        vim.api.nvim_create_autocmd("BufReadPost", {
          callback = function()
             local mark = vim.api.nvim_buf_get_mark(0, '"')
             if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
               vim.api.nvim_win_set_cursor(0, mark)
             end
          end,
        })

        -- Floating terminal toggle (no plugins)
        local float_term = { buf = nil, win = nil }

        function FloatTermToggle()
          if float_term.win and vim.api.nvim_win_is_valid(float_term.win) then
            vim.api.nvim_win_hide(float_term.win)
            float_term.win = nil
            return
          end

          local width  = math.floor(vim.o.columns * 0.8)
          local height = math.floor(vim.o.lines * 0.8)
          local col    = math.floor((vim.o.columns - width) / 2)
          local row    = math.floor((vim.o.lines - height) / 2)

          if not (float_term.buf and vim.api.nvim_buf_is_valid(float_term.buf)) then
            float_term.buf = vim.api.nvim_create_buf(false, true)
          end

          float_term.win = vim.api.nvim_open_win(float_term.buf, true, {
            relative = "editor",
            width    = width,
            height   = height,
            col      = col,
            row      = row,
            style    = "minimal",
            border   = "rounded",
          })

          -- Terminal needs a solid background; override NormalFloat transparency
          vim.wo[float_term.win].winhighlight = "NormalFloat:Normal"

          if vim.bo[float_term.buf].buftype ~= "terminal" then
            local shell_str = os.getenv("SHELL") or "/bin/bash"
            local shell_parts = vim.split(vim.trim(shell_str), "%s+")
            table.insert(shell_parts, "-i")
            vim.fn.termopen(shell_parts, { env = { TERM = "xterm-256color" } })
          end
          vim.cmd("startinsert")
        end

        vim.keymap.set({ "n", "t" }, "<C-t>", FloatTermToggle, { desc = "Toggle floating terminal" })

        -- Transparency
        vim.api.nvim_set_hl(0, "Normal",      { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalNC",    { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        vim.api.nvim_set_hl(0, "SignColumn",  { bg = "none" })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
      '';

      # ── Keymaps ───────────────────────────────────────────────────────────
      keymaps = [
        # File explorer
        {mode = "n"; key = "-"; action = "<CMD>Oil<CR>"; options.desc = "Open parent directory";}
        {mode = "n"; key = "<leader>nt"; action = "<CMD>NvimTreeToggle<CR>"; options.desc = "Toggle file tree";}
        {mode = "n"; key = "<leader>c"; action = ":nohlsearch<CR>"; options.desc = "Clear search highlight";}
        {mode = "x"; key = "<leader>p"; action = "\"_dP"; options.desc = "Paste without yanking";}
        {mode = ["n" "v"]; key = "<leader>x"; action = "\"_d"; options.desc = "Delete without yanking";}

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

        {mode = "n"; key = "<leader>sv"; action = ":vsplit<CR>"; options.desc = "Split window vertically";}
        {mode = "n"; key = "<leader>sh"; action = ":split<CR>"; options.desc = "Split window horizontally";}
        {mode = "n"; key = "<C-Up>"; action = ":resize +2<CR>"; options.desc = "Increase the window height";}
        {mode = "n"; key = "<C-Down>"; action = ":resize -2<CR>"; options.desc = "Decrease the window height";}
        {mode = "n"; key = "<C-Left>"; action = ":vertical resize -2<CR>"; options.desc = "Decrease the window width";}
        {mode = "n"; key = "<C-Right>"; action = ":vertical resize +2<CR>"; options.desc = "Increase the window width";}

        {mode = "n"; key = "<A-j>"; action = ":m .+1<CR>=="; options.desc = "Move line down";}
        {mode = "n"; key = "<A-k>"; action = ":m .-2<CR>=="; options.desc = "Move line up";}
        {mode = "v"; key = "<A-j>"; action = ":m '>+1<CR>gv=gv"; options.desc = "Move selection down";}
        {mode = "v"; key = "<A-k>"; action = ":m '<-2<CR>gv=gv"; options.desc = "Move selection up";}

        {mode = "v"; key = "<"; action = "<gv"; options.desc = "Indent left and reselect";}
        {mode = "v"; key = ">"; action = ">gv"; options.desc = "Indent right and reselect";}

        {mode = "n"; key = "J"; action = "mzJ`z"; options.desc = "Join lines and keep cursor position";}



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
