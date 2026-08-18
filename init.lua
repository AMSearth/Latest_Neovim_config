-- ==========================================================================
-- 1. BASIC SETTINGS & LEADER KEY
-- ==========================================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Essential Editor Options
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
vim.opt.timeoutlen = 1000          -- Decrease mapped sequence wait time
vim.opt.splitright = true          -- Split windows to the right
vim.opt.splitbelow = true          -- Split windows to the bottom
vim.opt.list = true                -- Show some invisible characters
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'       -- Preview substitutions live
vim.opt.cursorline = true          -- Highlight current line
vim.opt.scrolloff = 10             -- Keep 10 lines above/below cursor
vim.opt.clipboard = 'unnamedplus'  -- Sync system clipboard
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Basic Keymaps
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
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
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/williamboman/mason.nvim',
  'https://github.com/williamboman/mason-lspconfig.nvim',
  'https://github.com/hrsh7th/nvim-cmp',
  'https://github.com/hrsh7th/cmp-nvim-lsp',
  'https://github.com/hrsh7th/cmp-path',
  'https://github.com/L3MON4D3/LuaSnip',
  'https://github.com/saadparwaiz1/cmp_luasnip',
  'https://github.com/windwp/nvim-autopairs',
  'https://github.com/echasnovski/mini.icons',
  'https://github.com/echasnovski/mini.statusline',
  'https://github.com/lewis6991/gitsigns.nvim',
})


-- ==========================================================================
-- 3. PLUGIN CONFIGURATION
-- ==========================================================================

-- ------------------------------------------------------------------------
-- Theme: Tokyo Night
-- ------------------------------------------------------------------------
vim.cmd.colorscheme('tokyonight-moon') 

-- ------------------------------------------------------------------------
-- Icons & Statusline: mini.icons & mini.statusline
-- ------------------------------------------------------------------------
require('mini.icons').setup()

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

local statusline = require('mini.statusline')
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

-- ------------------------------------------------------------------------
-- Git Status Signs: gitsigns.nvim
-- ------------------------------------------------------------------------
require('gitsigns').setup({
  signs = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

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

-- ------------------------------------------------------------------------
-- File Searching: Telescope
-- ------------------------------------------------------------------------
local telescope = require('telescope')
telescope.setup({
  -- Tell Telescope to include hidden files in its searches
  pickers = {
    find_files = {
      hidden = true,
    },
  },
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",        -- Search hidden files for Live Grep
      "--glob=!.git/*",  -- ...but keep ignoring the .git folder!
    },
  },
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown(),
    },
  },
})
pcall(telescope.load_extension, 'ui-select')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

-- ------------------------------------------------------------------------
-- LSP Configuration & Mason (Language Servers) - v2.0+ Compatible
-- ------------------------------------------------------------------------
require('mason').setup()

-- 1. Setup global capabilities for nvim-cmp auto-completion
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

-- 2. Configure specific servers via the new native vim.lsp.config API
-- (You only need to do this for servers that require custom settings)
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
    },
  },
})

-- 3. Initialize mason-lspconfig
-- In v2.0+, this automatically enables any server you install via Mason!
-- No setup_handlers required.
require('mason-lspconfig').setup()

-- 4. Keybindings for when an LSP attaches
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
    map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
  end,
})

-- ------------------------------------------------------------------------
-- Auto-completion: nvim-cmp
-- ------------------------------------------------------------------------
local cmp = require('cmp')
local luasnip = require('luasnip')

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
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
})

-- ------------------------------------------------------------------------
-- Auto-pairing: nvim-autopairs
-- ------------------------------------------------------------------------
require('nvim-autopairs').setup({
  check_ts = true, -- Use treesitter to check for a pair
})

-- Automatically add `(` after selecting a function or method from nvim-cmp
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

-- ==========================================================================
-- END OF CONFIG
-- ==========================================================================

