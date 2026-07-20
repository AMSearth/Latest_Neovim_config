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
vim.opt.showmode = false           -- Don't show mode in command line
vim.opt.breakindent = true         -- Enable break indent
vim.opt.undofile = true            -- Save undo history
vim.opt.ignorecase = true          -- Case-insensitive searching
vim.opt.smartcase = true           -- Case-sensitive if capital letter included
vim.opt.signcolumn = 'yes'         -- Always show the signcolumn
vim.opt.updatetime = 250           -- Decrease update time
vim.opt.timeoutlen = 1000           -- Decrease mapped sequence wait time
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
})


-- ==========================================================================
-- 3. PLUGIN CONFIGURATION
-- ==========================================================================

-- ------------------------------------------------------------------------
-- Theme: Tokyo Night
-- ------------------------------------------------------------------------
vim.cmd.colorscheme('tokyonight-moon') 

-- ------------------------------------------------------------------------
-- File Searching: Telescope
-- ------------------------------------------------------------------------
local telescope = require('telescope')
telescope.setup({
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
-- ==========================================================================
-- END OF CONFIG
-- ==========================================================================
