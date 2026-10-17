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
vim.opt.updatetime = 500         -- Lower disk I/O, keeps diagnostics responsive
vim.opt.swapfile = false         -- Prevent continuous disk I/O

-- ==========================================================================
-- 3. THEME & TRANSPARENCY
-- ==========================================================================
-- Force transparent background (Main UI only, so floating popups remain readable)
local theme_augroup = vim.api.nvim_create_augroup('potato-theme', { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = theme_augroup,
  pattern = "*",
  callback = function()
    local transparent_groups = { "Normal", "NormalNC", "SignColumn", "LineNr", "EndOfBuffer" }
    for _, group in ipairs(transparent_groups) do
      vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
    end
  end,
})
vim.cmd.colorscheme('habamax') -- Apply theme with transparency patch

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
local security_augroup = vim.api.nvim_create_augroup('potato-security', { clear = true })
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  group = security_augroup,
  desc = 'Disable persistent undo & swap for sensitive files',
  pattern = { '/tmp/*', '/dev/shm/*', '*.env', '*.env.*', '*.secret', '*.pem', '*.key', 'id_rsa*' },
  callback = function() vim.opt_local.undofile = false end,
})

-- Auto-refresh buffers when files are changed outside Neovim (e.g., git checkout)
local buffer_augroup = vim.api.nvim_create_augroup('potato-buffer-refresh', { clear = true })
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = buffer_augroup,
  desc = 'Check if buffers changed on disk',
  callback = function()
    if vim.bo.buftype ~= 'nofile' and vim.bo.buftype ~= 'terminal' then
      vim.cmd('checktime')
    end
  end,
})

-- Close helper/floating windows instantly with 'q' (README keybinding)
local helper_augroup = vim.api.nvim_create_augroup('potato-helper-windows', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = helper_augroup,
  desc = 'Close helper windows with q',
  pattern = { 'help', 'netrw', 'qf', 'checkhealth', 'lspinfo' },
  callback = function(event)
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = event.buf, silent = true, nowait = true })
  end,
})

-- Highlight Yanked Text
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

-- ==========================================================================
-- 6. KEYMAPS
-- ==========================================================================
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix / location list' })
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
-- 7. BARE MINIMUM PLUGINS
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

-- Diagnostics & Git (v0.11 FIX: Future-proof enum indexing)
vim.diagnostic.config({
  signs = { text = { 
    [vim.diagnostic.severity.ERROR] = 'E', 
    [vim.diagnostic.severity.WARN]  = 'W', 
    [vim.diagnostic.severity.INFO]  = 'I', 
    [vim.diagnostic.severity.HINT]  = 'H' 
  }},
  virtual_text = true, severity_sort = true, float = { border = 'rounded' },
})

local gitsigns_ok, gitsigns = pcall(require, 'gitsigns')
if gitsigns_ok then
  gitsigns.setup({
    signs = { add = { text = '┃' }, change = { text = '┃' } },
    on_attach = function(bufnr)
      local map = function(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation between Git hunks
      map('n', ']c', function()
        if vim.wo.diff then return ']c' end
        vim.schedule(function() gitsigns.nav_hunk('next') end)
        return '<Ignore>'
      end, { expr = true, desc = 'Next Git change (hunk)' })

      map('n', '[c', function()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gitsigns.nav_hunk('prev') end)
        return '<Ignore>'
      end, { expr = true, desc = 'Previous Git change (hunk)' })

      -- Git Hunk Actions
      map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Preview Git hunk' })
      map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Stage Git hunk' })
      map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Reset (undo) Git hunk' })
      map('v', '<leader>hs', function() gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { desc = 'Stage Git hunk' })
      map('v', '<leader>hr', function() gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { desc = 'Reset Git hunk' })
    end,
  })
end

-- Treesitter (Syntax Highlighting)
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

-- Telescope (Fuzzy Finder)
local telescope_ok, telescope = pcall(require, 'telescope')
if telescope_ok then
  local previewers = require('telescope.previewers')
  local safe_previewer_maker = function(filepath, bufnr, opts)
    filepath = vim.fn.expand(filepath)
    local stat = (vim.uv or vim.loop).fs_stat(filepath)
    if stat and stat.size > 100000 then return end
    previewers.buffer_previewer_maker(filepath, bufnr, opts)
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

-- Set default capabilities and root markers globally for all native servers
vim.lsp.config('*', {
  capabilities = caps,
  root_markers = { '.git' },
})

vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
  settings = { Lua = { diagnostics = { globals = { 'vim' } } } }
})
if vim.fn.executable('lua-language-server') == 1 then vim.lsp.enable('lua_ls') end

vim.lsp.config('pyright', {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
  settings = { python = { analysis = { autoSearchPaths = true, diagnosticMode = 'openFilesOnly', typeCheckingMode = 'basic' } } }
})
if vim.fn.executable('pyright-langserver') == 1 then vim.lsp.enable('pyright') end

vim.lsp.config('ts_ls', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { 'tsconfig.json', 'package.json', 'jsconfig.json', '.git' },
})
if vim.fn.executable('typescript-language-server') == 1 then vim.lsp.enable('ts_ls') end

vim.lsp.config('html', {
  cmd = { 'vscode-html-language-server', '--stdio' },
  filetypes = { 'html' },
  root_markers = { 'package.json', '.git' },
})
if vim.fn.executable('vscode-html-language-server') == 1 then vim.lsp.enable('html') end

vim.lsp.config('cssls', {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_markers = { 'package.json', '.git' },
})
if vim.fn.executable('vscode-css-language-server') == 1 then vim.lsp.enable('cssls') end

vim.lsp.config('jsonls', {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  root_markers = { 'package.json', '.git' },
})
if vim.fn.executable('vscode-json-language-server') == 1 then vim.lsp.enable('jsonls') end

vim.lsp.config('clangd', {
  cmd = { 'clangd', '--background-index=false' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
  root_markers = { '.clangd', 'compile_commands.json', 'compile_flags.txt', '.git' },
})
if vim.fn.executable('clangd') == 1 then vim.lsp.enable('clangd') end

local lsp_augroup = vim.api.nvim_create_augroup('potato-lsp-attach', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
  group = lsp_augroup,
  callback = function(event)
    local map = function(mode, keys, func, desc)
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
    end
    map('n', 'gd', vim.lsp.buf.definition, 'Goto Definition')
    map('n', 'gr', vim.lsp.buf.references, 'Goto References')
    map('n', 'K', vim.lsp.buf.hover, 'Hover Documentation')
    map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename Variable')
    map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'Code Action')
    map('n', '<leader>cd', vim.diagnostic.open_float, 'Code Diagnostic Popup')
    map('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next Diagnostic')
    map('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Previous Diagnostic')
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
    sources = {
      { name = 'nvim_lsp' },
      { name = 'path' },
      { name = 'buffer', keyword_length = 3 },
    },
  })
end

-- v0.11 FIX: Link Autopairs back to CMP so functions autocomplete with `()`
local autopairs_ok, autopairs = pcall(require, 'nvim-autopairs')
if autopairs_ok then 
  autopairs.setup({ check_ts = true }) 
  local cmp_autopairs_ok, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')
  if cmp_autopairs_ok and cmp_ok then
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end
end

-- ------------------------------------------------------------------------
-- 11. FORMATTER (Prettier + LSP Fallback)
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
  if not prettier then return false end

  local stdin_path = filepath ~= '' and filepath or (ft ~= '' and ('dummy.' .. ft) or 'dummy.txt')
  local args = { prettier, '--stdin-filepath', stdin_path }
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local input = table.concat(lines, '\n')

  local res = vim.system(args, { stdin = input }):wait()
  if res.code == 0 and res.stdout and #res.stdout > 0 then
    local new_lines = vim.split(res.stdout, '\n', { plain = true })
    if #new_lines > 0 and new_lines[#new_lines] == '' then table.remove(new_lines, #new_lines) end
    if table.concat(lines, '\n') ~= table.concat(new_lines, '\n') then
      local is_current = (bufnr == vim.api.nvim_get_current_buf())
      local view = is_current and vim.fn.winsaveview() or nil
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
      if view then vim.fn.winrestview(view) end
    end
    return true
  end
  return false
end

vim.g.prettier_autoformat = true

-- Unified Universal Formatting (Tries Prettier, falls back to LSP)
vim.keymap.set('n', '<leader>cf', function() 
  if not format_with_prettier({ silent = true }) then
    vim.lsp.buf.format({ async = true })
  end
end, { desc = '[C]ode [F]ormat (Universal)' })

-- Formatter shortcut alias matching README (<leader>cp)
vim.keymap.set('n', '<leader>cp', function() 
  if not format_with_prettier({ silent = true, force = true }) then
    vim.lsp.buf.format({ async = true })
  end
end, { desc = '[C]ode [P]rettier format' })

vim.keymap.set('n', '<leader>tp', function()
  vim.g.prettier_autoformat = not vim.g.prettier_autoformat
  vim.notify('Prettier auto-format ' .. (vim.g.prettier_autoformat and 'ON' or 'OFF'))
end, { desc = '[T]oggle format-on-save' })

vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Auto-format buffer on save',
  group = vim.api.nvim_create_augroup('kickstart-format-on-save', { clear = true }),
  callback = function(event)
    if vim.g.prettier_autoformat then
      -- Attempt prettier. If it returns false (e.g. unsupported C++ file), do nothing.
      format_with_prettier({ bufnr = event.buf, silent = true })
    end
  end,
})
