-- 1. Enable fast Lua bytecode loader cache
if vim.loader then vim.loader.enable() end

-- ==========================================================================
-- 2. PERFORMANCE OPTIMIZATIONS (POTATO PC)
-- ==========================================================================
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0

-- Disable heavy, unused legacy Vim plugins
local disabled_built_ins = {
  "gzip", "zip", "zipPlugin", "tar", "tarPlugin",
  "getscript", "getscriptPlugin", "vimball", "vimballPlugin",
  "2html_plugin", "logipat", "rrhelper", "spellfile_plugin", "matchit"
}
for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end

vim.opt.shada = "'20,<50,s10,h"  -- Limit history file size to prevent slow startups
vim.opt.synmaxcol = 200          -- Stop syntax highlighting on long lines (minified JS/CSS)
vim.opt.updatetime = 500         -- Lower disk I/O, but keeps diagnostics responsive
vim.opt.swapfile = false         -- Prevent continuous disk I/O

-- ==========================================================================
-- 3. THEME & TRANSPARENCY
-- ==========================================================================
vim.cmd.colorscheme('habamax')

-- Force transparent background (Main UI only, so floating popups remain readable)
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local transparent_groups = { "Normal", "NormalNC", "SignColumn", "LineNr", "EndOfBuffer" }
    for _, group in ipairs(transparent_groups) do
      vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
    end
  end,
})
vim.cmd.colorscheme('habamax') -- Trigger the transparency patch

-- ==========================================================================
-- 4. BASIC SETTINGS & ERGONOMICS
-- ==========================================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.background = 'dark'
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.clipboard = 'unnamedplus'
vim.opt.confirm = true
vim.opt.smoothscroll = true
vim.opt.virtualedit = 'block'
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.modeline = true
vim.opt.modelines = 3

-- Configure Native File Explorer (Netrw)
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
vim.g.netrw_liststyle = 3
vim.keymap.set('n', '<leader>e', '<cmd>Lexplore<CR>', { desc = 'Toggle File [E]xplorer (Netrw)' })

-- ==========================================================================
-- 5. ROBUSTNESS & SECURITY AUTOCOMMANDS
-- ==========================================================================

-- Security: Prevent saving undo history for sensitive credentials
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  desc = 'Disable persistent undo & swap for sensitive files',
  pattern = { '/tmp/*', '/dev/shm/*', '*.env', '*.env.*', '*.secret', '*.pem', '*.key', 'id_rsa*' },
  callback = function() vim.opt_local.undofile = false end,
})

-- Auto-refresh buffers when files are changed outside Neovim (e.g., git checkout)
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  desc = 'Check if buffers changed on disk',
  callback = function()
    if vim.o.buftype ~= 'nofile' then vim.cmd('checktime') end
  end,
})

-- Highlight Yanked Text (v0.11 FIX: using vim.highlight instead of vim.hl)
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

-- ==========================================================================
-- 6. KEYMAPS
-- ==========================================================================
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus left' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus right' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus down' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus up' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right' })
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- ==========================================================================
-- 7. BARE MINIMUM PLUGINS (No Mason, No nvim-lspconfig)
-- ==========================================================================
vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/windwp/nvim-ts-autotag',
  'https://github.com/echasnovski/mini.surround',
  'https://github.com/hrsh7th/nvim-cmp',
  'https://github.com/hrsh7th/cmp-nvim-lsp',
  'https://github.com/hrsh7th/cmp-path',
  'https://github.com/hrsh7th/cmp-buffer',
  'https://github.com/windwp/nvim-autopairs',
  'https://github.com/lewis6991/gitsigns.nvim',
})

-- ==========================================================================
-- 8. PLUGIN CONFIGURATION
-- ==========================================================================
vim.diagnostic.config({
  signs = { text = { [1] = 'E', [2] = 'W', [3] = 'I', [4] = 'H' } },
  virtual_text = true, severity_sort = true, float = { border = 'rounded' },
})

local gitsigns_ok, gitsigns = pcall(require, 'gitsigns')
if gitsigns_ok then gitsigns.setup({ signs = { add = { text = '┃' }, change = { text = '┃' } } }) end

local treesitter_ok, treesitter_configs = pcall(require, 'nvim-treesitter.configs')
if treesitter_ok then
  treesitter_configs.setup({
    ensure_installed = {}, auto_install = false, sync_install = false,
    highlight = {
      enable = true,
      disable = function(_, buf)
        local max_filesize = 50 * 1024 
        local ok, stats = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(buf))
        return ok and stats and stats.size > max_filesize
      end,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
  })
end

local autotag_ok, autotag = pcall(require, 'nvim-ts-autotag')
if autotag_ok then autotag.setup({ opts = { enable_close = true } }) end
local surround_ok, surround = pcall(require, 'mini.surround')
if surround_ok then surround.setup() end

local telescope_ok, telescope = pcall(require, 'telescope')
if telescope_ok then
  local previewers = require('telescope.previewers')
  local safe_previewer_maker = function(filepath, bufnr, opts)
    filepath = vim.fn.expand(filepath)
    local stat = (vim.uv or vim.loop).fs_stat(filepath)
    if stat and stat.size < 100000 then previewers.buffer_previewer_maker(filepath, bufnr, opts) end
  end
  telescope.setup({ defaults = { buffer_previewer_maker = safe_previewer_maker, file_ignore_patterns = { '%.git/', 'node_modules/.*' } } })
  local builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
end

-- ------------------------------------------------------------------------
-- 9. LSP CONFIGURATION (Native Neovim v0.11+)
-- ------------------------------------------------------------------------
local caps = vim.lsp.protocol.make_client_capabilities()
local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if cmp_lsp_ok then
  caps = vim.tbl_deep_extend('force', caps, cmp_nvim_lsp.default_capabilities())
end

-- v0.11 FEATURE: Set default capabilities for ALL servers dynamically
vim.lsp.config('*', { capabilities = caps })

-- 1. Lua
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  settings = { Lua = { diagnostics = { globals = { 'vim' } } } }
})
if vim.fn.executable('lua-language-server') == 1 then vim.lsp.enable('lua_ls') end

-- 2. Python (Pyright)
vim.lsp.config('pyright', {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  settings = { python = { analysis = { autoSearchPaths = true, diagnosticMode = 'openFilesOnly', typeCheckingMode = 'basic' } } }
})
if vim.fn.executable('pyright-langserver') == 1 then vim.lsp.enable('pyright') end

-- 3. Web Dev (TypeScript / JS)
vim.lsp.config('ts_ls', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
})
if vim.fn.executable('typescript-language-server') == 1 then vim.lsp.enable('ts_ls') end

-- 4. Clangd (C/C++)
vim.lsp.config('clangd', {
  cmd = { 'clangd', '--background-index=false' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
})
if vim.fn.executable('clangd') == 1 then vim.lsp.enable('clangd') end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local map = function(keys, func, desc) vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc }) end
    map('gd', vim.lsp.buf.definition, 'Goto Definition')
    map('gr', vim.lsp.buf.references, 'Goto References')
    map('<leader>rn', vim.lsp.buf.rename, 'Rename Variable')
    map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
    map('<leader>cd', vim.diagnostic.open_float, 'Code Diagnostic Popup')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')

    -- v0.11 FIX: goto_next/prev is deprecated. Used the new vim.diagnostic.jump()
    map(']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next Diagnostic')
    map('[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Previous Diagnostic')
  end,
})

-- ------------------------------------------------------------------------
-- 10. AUTO-COMPLETION & AUTO-PAIRS
-- ------------------------------------------------------------------------
local cmp_ok, cmp = pcall(require, 'cmp')
if cmp_ok then
  cmp.setup({
    snippet = { expand = function(args) vim.snippet.expand(args.body) end },
    mapping = cmp.mapping.preset.insert({
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = { { name = 'nvim_lsp' }, { name = 'buffer', keyword_length = 3 } },
  })
end

local autopairs_ok, autopairs = pcall(require, 'nvim-autopairs')
if autopairs_ok then autopairs.setup({ check_ts = true }) end

-- ------------------------------------------------------------------------
-- 11. FORMATTER: PRETTIER
-- ------------------------------------------------------------------------
local prettier_supported_fts = {
  javascript = true, javascriptreact = true, typescript = true, typescriptreact = true,
  css = true, scss = true, html = true, json = true, yaml = true, markdown = true,
}

local function get_prettier_bin()
  local local_bin = vim.fn.findfile('node_modules/.bin/prettier', '.;')
  if local_bin ~= '' and vim.fn.executable(local_bin) == 1 then return vim.fn.fnamemodify(local_bin, ':p') end
  local path_bin = vim.fn.exepath('prettier')
  if path_bin ~= '' then return path_bin end
  return nil
end

local function format_with_prettier(opts)
  opts = opts or {}
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then return false end

  local ft = vim.bo[bufnr].filetype
  if not prettier_supported_fts[ft] and not opts.force then return false end

  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath ~= '' then
    local stat = (vim.uv or vim.loop).fs_stat(filepath)
    if stat and stat.size > 50000 then return false end
  end

  local prettier = get_prettier_bin()
  if not prettier then 
    if not opts.silent then vim.notify('Prettier not found globally (npm i -g prettier)', vim.log.levels.WARN) end
    return false 
  end

  local args = { prettier, '--stdin-filepath', filepath ~= '' and filepath or 'dummy.' .. ft }
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local input = table.concat(lines, '\n')

  local res = vim.system(args, { stdin = input }):wait()
  if res.code == 0 and res.stdout and #res.stdout > 0 then
    local new_lines = vim.split(res.stdout, '\n', { plain = true })
    if #new_lines > 0 and new_lines[#new_lines] == '' then table.remove(new_lines, #new_lines) end
    
    if table.concat(lines, '\n') ~= table.concat(new_lines, '\n') then
      local view = vim.fn.winsaveview()
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
      vim.fn.winrestview(view)
    end
    return true
  end
  return false
end

vim.g.format_with_prettier = format_with_prettier
vim.g.prettier_autoformat = true

vim.keymap.set('n', '<leader>cp', function() format_with_prettier({ force = true, silent = false }) end, { desc = '[C]ode [P]rettier Format' })
vim.keymap.set('n', '<leader>tp', function()
  vim.g.prettier_autoformat = not vim.g.prettier_autoformat
  vim.notify('Prettier auto-format ' .. (vim.g.prettier_autoformat and 'ON' or 'OFF'))
end, { desc = 'Toggle auto-format' })

vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Auto-format buffer with Prettier on save',
  group = vim.api.nvim_create_augroup('kickstart-format-on-save', { clear = true }),
  callback = function(event)
    if vim.g.prettier_autoformat then
      format_with_prettier({ bufnr = event.buf, silent = true })
    end
  end,
})
