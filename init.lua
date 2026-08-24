-- Enable Neovim fast Lua bytecode loader cache
if vim.loader then
  vim.loader.enable()
end

-- ==========================================================================
-- 1. BASIC SETTINGS & LEADER KEY
-- ==========================================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Essential Editor Options
vim.opt.background = 'dark'        -- Avoid terminal DSR latency on startup
vim.opt.termguicolors = true       -- Enable true color support
vim.opt.number = true              -- Show line numbers
vim.opt.relativenumber = true      -- Show relative line numbers
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.mouse = 'a'                -- Enable mouse mode
vim.opt.showmode = false           -- Don't show mode in command line (handled by statusline)
vim.opt.breakindent = true         -- Enable break indent
vim.opt.undofile = true            -- Save undo history
vim.opt.ignorecase = true          -- Case-insensitive searching
vim.opt.smartcase = true           -- Case-sensitive if capital letter included
vim.opt.signcolumn = 'yes'         -- Always show the signcolumn
vim.opt.updatetime = 250           -- Decrease update time
vim.opt.timeoutlen = 300           -- Fast mapped sequence wait time (300ms for instant leader response)
vim.opt.splitright = true          -- Split windows to the right
vim.opt.splitbelow = true          -- Split windows to the bottom
vim.opt.list = true                -- Show some invisible characters
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'       -- Preview substitutions live
vim.opt.cursorline = true          -- Highlight current line
vim.opt.scrolloff = 10             -- Keep 10 lines above/below cursor
vim.opt.clipboard = 'unnamedplus'  -- Sync system clipboard
vim.opt.confirm = true            -- Confirm to save changes before exiting modified buffer (Kickstart/LazyVim)
vim.opt.smoothscroll = true       -- Smooth scrolling on wrapped lines (LazyVim)
vim.opt.virtualedit = 'block'     -- Allow cursor to move where there is no text in visual block mode (LazyVim)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.modeline = true            -- Enable modelines
vim.opt.modelines = 5              -- Check only top/bottom 5 lines for performance

-- Security: Prevent saving undo history or swap files for sensitive credentials
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  desc = 'Disable persistent undo & swap for sensitive files',
  pattern = { '/tmp/*', '/dev/shm/*', '*.env', '*.env.*', '*.secret', '*.pem', '*.key', 'id_rsa*' },
  callback = function()
    vim.opt_local.undofile = false
    vim.opt_local.swapfile = false
  end,
})

-- Basic Keymaps & Ergonomics (Kickstart / LazyVim / NvChad)
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Seamless Window Navigation Mappings (<C-h>, <C-j>, <C-k>, <C-l>)
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Terminal Mode Ergonomics
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Visual Mode Indent & Move Lines (LazyVim / NvChad standard)
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left and retain selection' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right and retain selection' })
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Auto-sync buffers when files change on disk (LazyVim / NvChad)
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  desc = 'Check if buffers changed on disk',
  callback = function()
    if vim.o.buftype ~= 'nofile' then
      vim.cmd('checktime')
    end
  end,
})

-- Restore cursor to last position when reopening a file (Kickstart / LazyVim / NvChad)
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Go to last cursor position when opening buffer',
  callback = function(event)
    local exclude = { 'gitcommit', 'gitrebase' }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_pos then
      return
    end
    vim.b[buf].last_pos = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-resize window splits on terminal window resize (LazyVim / NvChad)
vim.api.nvim_create_autocmd('VimResized', {
  desc = 'Auto-resize splits when window is resized',
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd('tabdo wincmd =')
    vim.cmd('tabnext ' .. current_tab)
  end,
})

-- Quick-close helper windows with 'q' (Kickstart / LazyVim)
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Close helper buffers with q',
  pattern = { 'help', 'lspinfo', 'man', 'notify', 'qf', 'query', 'checkhealth' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = event.buf, silent = true, desc = 'Quit helper buffer' })
  end,
})


-- ==========================================================================
-- 2. NATIVE PLUGIN INSTALLATION (vim.pack)
-- ==========================================================================
-- Using Neovim 0.12+ built-in `vim.pack.add` to install and load plugins.
-- On first boot, Neovim will prompt you to install missing plugins.
vim.pack.add({
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-telescope/telescope-ui-select.nvim',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/windwp/nvim-ts-autotag',
  'https://github.com/echasnovski/mini.surround',
  'https://github.com/catgoose/nvim-colorizer.lua',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/williamboman/mason.nvim',
  'https://github.com/williamboman/mason-lspconfig.nvim',
  'https://github.com/hrsh7th/nvim-cmp',
  'https://github.com/hrsh7th/cmp-nvim-lsp',
  'https://github.com/hrsh7th/cmp-path',
  'https://github.com/hrsh7th/cmp-buffer',
  'https://github.com/L3MON4D3/LuaSnip',
  'https://github.com/saadparwaiz1/cmp_luasnip',
  'https://github.com/windwp/nvim-autopairs',
  'https://github.com/echasnovski/mini.icons',
  'https://github.com/echasnovski/mini.statusline',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/nvim-tree/nvim-tree.lua',
})


-- ==========================================================================
-- 3. PLUGIN CONFIGURATION
-- ==========================================================================

-- ------------------------------------------------------------------------
-- Keymap Popup & Hints: which-key.nvim
-- ------------------------------------------------------------------------
-- Keymap Popup & Hints: which-key.nvim
-- ------------------------------------------------------------------------
local wk_ok, wk = pcall(require, 'which-key')
if wk_ok then
  wk.setup({
    delay = 300,
  })
  wk.add({
    { '<leader>e', desc = 'Toggle File [E]xplorer' },
    { '<leader>s', group = '[S]earch' },
    { '<leader>r', group = '[R]ename' },
    { '<leader>c', group = '[C]ode' },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk' },
  })
end

-- ------------------------------------------------------------------------
-- Theme: Tokyo Night (with Terminal Transparency)
-- ------------------------------------------------------------------------
local tokyonight_ok, tokyonight = pcall(require, 'tokyonight')
if tokyonight_ok then
  tokyonight.setup({
    transparent = true,
    styles = {
      sidebars = 'transparent',
      floats = 'transparent',
    },
  })
  pcall(vim.cmd.colorscheme, 'tokyonight-moon')
end

-- ------------------------------------------------------------------------
-- Custom LSP Diagnostic Signs & UI
-- ------------------------------------------------------------------------
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN]  = '󰀦 ',
      [vim.diagnostic.severity.INFO]  = '󰋼 ',
      [vim.diagnostic.severity.HINT]  = '󰌵 ',
    },
  },
  virtual_text = true,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'if_many',
  },
})

-- ------------------------------------------------------------------------
-- Icons & Statusline: mini.icons & mini.statusline
-- ------------------------------------------------------------------------
local icons_ok, icons = pcall(require, 'mini.icons')
if icons_ok then
  icons.setup()
  pcall(icons.mock_nvim_web_devicons)
end

-- ------------------------------------------------------------------------
-- File Explorer: nvim-tree (VS Code-like sidebar)
-- ------------------------------------------------------------------------
-- Disable netrw for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local nvim_tree_ok, nvim_tree = pcall(require, 'nvim-tree')
if nvim_tree_ok then
  nvim_tree.setup({
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
    view = {
      width = 34,
      side = 'left',
    },
    renderer = {
      highlight_git = true,
      icons = {
        show = {
          file = true,
          folder = true,
          folder_arrow = true,
          git = true,
        },
      },
    },
    filters = {
      dotfiles = false,
      custom = { '^.git$' },
    },
    update_focused_file = {
      enable = true,
      update_root = false,
    },
    git = {
      enable = true,
      ignore = false,
    },
  })

  -- <Space> e to toggle VS Code-like file explorer
  vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle File [E]xplorer' })

  -- Auto-close Neovim if nvim-tree is the last remaining window
  vim.api.nvim_create_autocmd('QuitPre', {
    callback = function()
      local tree_wins = {}
      local floating_wins = {}
      local wins = vim.api.nvim_list_wins()
      for _, w in ipairs(wins) do
        local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
        if bufname:match('NvimTree_') ~= nil then
          table.insert(tree_wins, w)
        end
        if vim.api.nvim_win_get_config(w).relative ~= '' then
          table.insert(floating_wins, w)
        end
      end
      if 1 == #wins - #floating_wins - #tree_wins then
        for _, w in ipairs(tree_wins) do
          vim.api.nvim_win_close(w, true)
        end
      end
    end,
  })
end

local mode_icons = {
  ['n']     = '󰋜 NORMAL',
  ['no']    = '󰋜 N-OPERATOR',
  ['nov']   = '󰋜 N-OPERATOR',
  ['noV']   = '󰋜 N-OPERATOR',
  ['no\22'] = '󰋜 N-OPERATOR',
  ['niI']   = '󰋜 NORMAL',
  ['niR']   = '󰋜 NORMAL',
  ['niV']   = '󰋜 NORMAL',
  ['nt']    = '󰋜 NORMAL',
  ['ntT']   = '󰋜 NORMAL',
  ['v']     = '󰈈 VISUAL',
  ['vs']    = '󰈈 VISUAL',
  ['V']     = '󰈈 V-LINE',
  ['Vs']    = '󰈈 V-LINE',
  ['\22']   = '󰈈 V-BLOCK',
  ['\22s']  = '󰈈 V-BLOCK',
  ['s']     = '󰈈 SELECT',
  ['S']     = '󰈈 S-LINE',
  ['\19']   = '󰈈 S-BLOCK',
  ['i']     = '󰏫 INSERT',
  ['ic']    = '󰏫 INSERT',
  ['ix']    = '󰏫 INSERT',
  ['R']     = '󰛔 REPLACE',
  ['Rc']    = '󰛔 REPLACE',
  ['Rx']    = '󰛔 REPLACE',
  ['Rv']    = '󰛔 V-REPLACE',
  ['Rvc']   = '󰛔 V-REPLACE',
  ['Rvx']   = '󰛔 V-REPLACE',
  ['c']     = '󰞷 COMMAND',
  ['cv']    = '󰞷 EX',
  ['ce']    = '󰞷 EX',
  ['r']     = '󰛔 PROMPT',
  ['rm']    = '󰛔 MORE',
  ['r?']    = '󰛔 CONFIRM',
  ['!']     = ' SHELL',
  ['t']     = ' TERMINAL',
}

local statusline_ok, statusline = pcall(require, 'mini.statusline')
if statusline_ok then
  statusline.setup({
    use_icons = true,
    content = {
      active = function()
        local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
        local raw_mode = vim.api.nvim_get_mode().mode
        local custom_mode = mode_icons[raw_mode] or (raw_mode:upper())

        local git           = statusline.section_git({ trunc_width = 40 })
        local diff          = statusline.section_diff({ trunc_width = 75 })
        local diagnostics   = statusline.section_diagnostics({ trunc_width = 75 })
        local filename      = statusline.section_filename({ trunc_width = 140 })
        local fileinfo      = statusline.section_fileinfo({ trunc_width = 120 })
        local location      = statusline.section_location({ trunc_width = 75 })

        return statusline.combine_groups({
          { hl = mode_hl, strings = { custom_mode } },
          { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics } },
          '%<',
          { hl = 'MiniStatuslineFilename', strings = { filename } },
          '%=',
          { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
          { hl = mode_hl, strings = { location } },
        })
      end,
    },
  })
end

-- ------------------------------------------------------------------------
-- Git Status Signs: gitsigns.nvim
-- ------------------------------------------------------------------------
local gitsigns_ok, gitsigns = pcall(require, 'gitsigns')
if gitsigns_ok then
  gitsigns.setup({
    signs = {
      add          = { text = '┃' },
      change       = { text = '┃' },
      delete       = { text = '_' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
      untracked    = { text = '┆' },
    },
    on_attach = function(bufnr)
      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation between git change hunks
      map('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal({ ']c', bang = true })
        else
          gitsigns.nav_hunk('next')
        end
      end, { desc = 'Jump to next git change' })

      map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal({ '[c', bang = true })
        else
          gitsigns.nav_hunk('prev')
        end
      end, { desc = 'Jump to previous git change' })

      -- Hunk Actions
      map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Git [H]unk [P]review' })
      map('n', '<leader>hb', gitsigns.blame_line, { desc = 'Git [H]unk [B]lame line' })
      map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Git [H]unk [S]tage' })
      map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Git [H]unk [R]eset' })
    end,
  })
end

-- ------------------------------------------------------------------------
-- Syntax Highlighting & Full-Stack Parsing: Treesitter
-- ------------------------------------------------------------------------
local treesitter_ok, treesitter_configs = pcall(require, 'nvim-treesitter.configs')
if treesitter_ok then
  treesitter_configs.setup({
    ensure_installed = {
      'lua', 'vim', 'vimdoc', 'bash',
      'c', 'cpp',
      'html', 'css', 'javascript', 'typescript', 'tsx',
      'python', 'json', 'json5', 'yaml', 'toml', 'sql',
      'markdown', 'markdown_inline', 'dockerfile',
    },
    auto_install = true,
    highlight = {
      enable = true,
      -- Performance: Disable on large files (> 100 KB) to prevent editor lag
      disable = function(lang, buf)
        local max_filesize = 100 * 1024
        local ok, stats = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
  })
end

-- Full-Stack HTML/JSX/TSX Auto-tagging & Auto-renaming
local autotag_ok, autotag = pcall(require, 'nvim-ts-autotag')
if autotag_ok then
  autotag.setup({
    opts = {
      enable_close = true,
      enable_rename = true,
      enable_close_on_slash = true,
    },
  })
end

-- Full-Stack Surround Operations (Quotes, Brackets, HTML Tags)
local surround_ok, surround = pcall(require, 'mini.surround')
if surround_ok then
  surround.setup()
end

-- Full-Stack Inline Color Highlighter (CSS, Tailwind, Hex, RGB, HSL)
local colorizer_ok, colorizer = pcall(require, 'colorizer')
if colorizer_ok then
  colorizer.setup({
    filetypes = { '*' },
    user_default_options = {
      RGB = true,
      RRGGBB = true,
      names = false,
      RRGGBBAA = true,
      AARRGGBB = true,
      rgb_fn = true,
      hsl_fn = true,
      css = true,
      css_fn = true,
      tailwind = true,
      mode = 'background',
    },
  })
end

-- ------------------------------------------------------------------------
-- File Searching: Telescope
-- ------------------------------------------------------------------------
local telescope_ok, telescope = pcall(require, 'telescope')
if telescope_ok then
  local previewers = require('telescope.previewers')

  -- Prevent previewing large files or binaries (avoids memory exhaustion / crashes)
  local _bad_extensions = {
    'sqlite3', 'db', 'png', 'jpg', 'jpeg', 'gif', 'webp', 'pdf', 'zip', 'tar',
    'gz', '7z', 'rar', 'pyc', 'so', 'dylib', 'dll', 'woff', 'woff2', 'ttf',
    'eot', 'mp4', 'mp3', 'mkv', 'avi', 'mov', 'iso', 'bin', 'exe'
  }

  -- Synchronous and thread-safe buffer previewer maker
  local safe_previewer_maker = function(filepath, bufnr, opts)
    opts = opts or {}
    filepath = vim.fn.expand(filepath)

    -- Check file extension against binary blacklist
    local ext = string.match(filepath, '%.([a-zA-Z0-9]+)$')
    if ext and vim.tbl_contains(_bad_extensions, string.lower(ext)) then
      return
    end

    -- Check file size synchronously (limit previews to 100KB to prevent memory exhaustion / race conditions)
    local stat = (vim.uv or vim.loop).fs_stat(filepath)
    if not stat or stat.size > 100000 then
      return
    end

    previewers.buffer_previewer_maker(filepath, bufnr, opts)
  end

  -- Detect fd / fdfind executable with fallback to rg
  local fd_cmd = vim.fn.executable('fd') == 1 and 'fd' or (vim.fn.executable('fdfind') == 1 and 'fdfind' or nil)
  local find_files_cmd = nil
  if fd_cmd then
    find_files_cmd = {
      fd_cmd,
      '--type', 'f',
      '--strip-cwd-prefix',
      '--hidden',
      '--exclude', '.git',
      '--exclude', '.venv',
      '--exclude', 'venv',
      '--exclude', 'env',
      '--exclude', 'node_modules',
      '--exclude', '__pycache__',
      '--exclude', '*.sqlite3',
      '--exclude', '*.pyc',
    }
  elseif vim.fn.executable('rg') == 1 then
    find_files_cmd = {
      'rg',
      '--files',
      '--hidden',
      '--glob=!.git/*',
      '--glob=!venv/*',
      '--glob=!.venv/*',
      '--glob=!env/*',
      '--glob=!node_modules/*',
      '--glob=!__pycache__/*',
      '--glob=!*.sqlite3',
      '--glob=!*.pyc',
    }
  end

  telescope.setup({
    defaults = {
      buffer_previewer_maker = safe_previewer_maker,
      file_ignore_patterns = {
        '%.git/',
        'venv/.*',
        '%.venv/.*',
        'env/.*',
        'node_modules/.*',
        '__pycache__/.*',
        '%.sqlite3',
        '%.db',
        '%.pyc',
        'staticfiles/.*',
        'media/.*',
      },
      vimgrep_arguments = {
        'rg',
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case',
        '--hidden',
        '--glob=!.git/*',
        '--glob=!venv/*',
        '--glob=!.venv/*',
        '--glob=!node_modules/*',
        '--glob=!__pycache__/*',
        '--glob=!*.sqlite3',
      },
    },
    pickers = {
      find_files = {
        hidden = true,
        find_command = find_files_cmd,
      },
    },
    extensions = {
      ['ui-select'] = {
        require('telescope.themes').get_dropdown(),
      },
    },
  })
  pcall(telescope.load_extension, 'ui-select')

  local builtin_ok, builtin = pcall(require, 'telescope.builtin')
  if builtin_ok then
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sb', builtin.current_buffer_fuzzy_find, { desc = '[S]earch current [B]uffer' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
  end
end

-- ------------------------------------------------------------------------
-- LSP Configuration & Mason (Language Servers) - Full Stack Ready
-- ------------------------------------------------------------------------
local mason_ok, mason = pcall(require, 'mason')
if mason_ok then
  mason.setup()
end

-- 1. Setup global capabilities for nvim-cmp auto-completion
local lspconfig_ok, lspconfig = pcall(require, 'lspconfig')
local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if lspconfig_ok and cmp_lsp_ok then
  local lspconfig_defaults = lspconfig.util.default_config
  lspconfig_defaults.capabilities = vim.tbl_deep_extend(
    'force',
    lspconfig_defaults.capabilities,
    cmp_nvim_lsp.default_capabilities()
  )
end

-- 2. Configure specific servers via the new native vim.lsp.config API
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
    },
  },
})

-- Full Stack Web: TypeScript / JavaScript / React / Next.js
vim.lsp.config('ts_ls', {
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayVariableTypeHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayVariableTypeHints = true,
      },
    },
  },
})

-- Full Stack Web: Tailwind CSS
vim.lsp.config('tailwindcss', {
  filetypes = { 'html', 'css', 'scss', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue', 'svelte' },
})

-- Full Stack Web: HTML & CSS
vim.lsp.config('html', {})
vim.lsp.config('cssls', {})

-- Full Stack Web: Emmet (HTML/JSX expansion)
vim.lsp.config('emmet_language_server', {
  filetypes = { 'css', 'html', 'javascriptreact', 'less', 'sass', 'scss', 'typescriptreact', 'vue' },
})

-- Full Stack Data & DevOps: JSON, Docker, SQL
vim.lsp.config('jsonls', {})
vim.lsp.config('dockerls', {})
vim.lsp.config('sqlls', {})

-- Backend: Python (Django / FastAPI / Flask)
vim.lsp.config('pyright', {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'openFilesOnly',
        ignore = { 'venv', '.venv', 'env', 'node_modules', '__pycache__' },
      },
    },
  },
})

-- Systems: C / C++
vim.lsp.config('clangd', {
  cmd = {
    'clangd',
    '--background-index',
    '--clang-tidy',
    '--header-insertion=iwyu',
    '--completion-style=detailed',
    '--function-arg-placeholders',
    '--fallback-style=llvm',
    '--enable-config',
    '--query-driver=/usr/bin/g++,/usr/bin/c++,/usr/bin/clang++,/usr/bin/*g++',
  },
})

-- Grammar & Docs: Markdown / Text / Git Commit
vim.lsp.config('harper_ls', {
  filetypes = { 'markdown', 'text', 'gitcommit' },
  settings = {
    ['harper-ls'] = {
      userDictPath = vim.fn.expand('~/.config/nvim/dict.txt'),
      linters = {
        spell_check = true,
        an_a = true,
        sentence_capitalization = true,
        repeated_words = true,
        long_sentences = true,
      },
    },
  },
})

-- 3. Initialize mason-lspconfig
local mason_lsp_ok, mason_lspconfig = pcall(require, 'mason-lspconfig')
if mason_lsp_ok then
  mason_lspconfig.setup()
end

-- 4. Keybindings & Autocmds for when an LSP attaches
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    local telescope_builtin = nil
    pcall(function() telescope_builtin = require('telescope.builtin') end)

    map('gd', telescope_builtin and telescope_builtin.lsp_definitions or vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('gr', telescope_builtin and telescope_builtin.lsp_references or vim.lsp.buf.references, '[G]oto [R]eferences')
    map('gI', telescope_builtin and telescope_builtin.lsp_implementations or vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    map('<leader>D', telescope_builtin and telescope_builtin.lsp_type_definitions or vim.lsp.buf.type_definition, 'Type [D]efinition')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('<leader>cf', function() vim.lsp.buf.format({ async = true }) end, '[C]ode [F]ormat Buffer')
    map('<leader>cd', vim.diagnostic.open_float, '[C]ode [D]iagnostic popup')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('[d', vim.diagnostic.goto_prev, 'Previous Diagnostic')
    map(']d', vim.diagnostic.goto_next, 'Next Diagnostic')

    -- Toggle Inlay Hints if supported by LSP (Kickstart standard)
    if client and client.supports_method('textDocument/inlayHint') then
      map('<leader>th', function()
        local current = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
        vim.lsp.inlay_hint.enable(not current, { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end

    -- Highlight symbol under cursor when idle (if supported by LSP)
    if client and client.supports_method('textDocument/documentHighlight') then
      local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight-' .. event.buf, { clear = true })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('lsp-detach-' .. event.buf, { clear = true }),
        callback = function(detach_event)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = 'lsp-highlight-' .. detach_event.buf })
        end,
      })
    end
  end,
})

-- ------------------------------------------------------------------------
-- Auto-completion: nvim-cmp
-- ------------------------------------------------------------------------
local cmp_ok, cmp = pcall(require, 'cmp')
local luasnip_ok, luasnip = pcall(require, 'luasnip')

if cmp_ok and luasnip_ok then
  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    completion = { completeopt = 'menu,menuone,noinsert' },
    mapping = cmp.mapping.preset.insert({
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-y>'] = cmp.mapping.confirm({ select = true }), -- Accept completion
      ['<C-Space>'] = cmp.mapping.complete({}),           -- Trigger completion manually
      -- Snippet Jump navigation
      ['<C-l>'] = cmp.mapping(function()
        if luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        end
      end, { 'i', 's' }),
      ['<C-h>'] = cmp.mapping(function()
        if luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        end
      end, { 'i', 's' }),
    }),
    sources = {
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'path' },
      { name = 'buffer', keyword_length = 3 },
    },
  })

  -- Clear LuaSnip session on leaving insert mode to prevent ghost jumps
  vim.api.nvim_create_autocmd('ModeChanged', {
    pattern = '*:n',
    callback = function()
      if ((vim.v.event.old_mode == 's' and vim.v.event.new_mode == 'n') or vim.v.event.old_mode == 'i')
          and luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
          and not luasnip.session.jump_active
      then
        luasnip.unlink_current()
      end
    end,
  })
end

-- ------------------------------------------------------------------------
-- Auto-pairing: nvim-autopairs
-- ------------------------------------------------------------------------
local autopairs_ok, autopairs = pcall(require, 'nvim-autopairs')
if autopairs_ok then
  autopairs.setup({
    check_ts = true, -- Use treesitter to check for a pair
  })

  -- Automatically add `(` after selecting a function or method from nvim-cmp
  if cmp_ok then
    local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end
end

-- ==========================================================================
-- END OF CONFIG
-- ==========================================================================

