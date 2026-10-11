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
vim.opt.updatetime = 250
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
vim.opt.modelines = 5

-- Set Built-in Native Colorscheme (Zero overhead)
vim.cmd.colorscheme('habamax')

-- Force transparent background to match terminal opacity
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local transparent_groups = {
      "Normal",       -- Main text background
      "NormalNC",     -- Non-current window background
      "NormalFloat",  -- Floating window backgrounds
      "FloatBorder",  -- Floating window borders
      "SignColumn",   -- The gutter where git signs/diagnostics live
      "LineNr",       -- Line number column
      "EndOfBuffer",  -- The empty space at the bottom of a file (the ~ symbols)
    }
    for _, group in ipairs(transparent_groups) do
      vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
    end
  end,
})

-- Re-apply the colorscheme to trigger the autocmd we just created
vim.cmd.colorscheme('habamax')

-- Disable unused legacy remote providers for instant startup
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

-- Configure Native File Explorer (Netrw) to act like a sidebar
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
vim.g.netrw_liststyle = 3 -- Tree view

-- Security: Prevent saving undo history or swap files for sensitive credentials
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  desc = 'Disable persistent undo & swap for sensitive files',
  pattern = { '/tmp/*', '/dev/shm/*', '*.env', '*.env.*', '*.secret', '*.pem', '*.key', 'id_rsa*' },
  callback = function()
    vim.opt_local.undofile = false
    vim.opt_local.swapfile = false
  end,
})

-- Basic Keymaps & Ergonomics
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

-- Toggle Native File Explorer (Netrw)
vim.keymap.set('n', '<leader>e', '<cmd>Lexplore<CR>', { desc = 'Toggle File [E]xplorer (Netrw)' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  desc = 'Check if buffers changed on disk',
  callback = function()
    if vim.o.buftype ~= 'nofile' then vim.cmd('checktime') end
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Go to last cursor position when opening buffer',
  callback = function(event)
    local exclude = { 'gitcommit', 'gitrebase' }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_pos then return end
    vim.b[buf].last_pos = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd('VimResized', {
  desc = 'Auto-resize splits when window is resized',
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd('tabdo wincmd =')
    vim.cmd('tabnext ' .. current_tab)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Close helper buffers with q',
  pattern = { 'help', 'lspinfo', 'man', 'notify', 'qf', 'query', 'checkhealth', 'netrw' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = event.buf, silent = true })
  end,
})

-- ==========================================================================
-- 2. NATIVE PLUGIN INSTALLATION (vim.pack) - BARE MINIMUM
-- ==========================================================================
vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/windwp/nvim-ts-autotag',
  'https://github.com/echasnovski/mini.surround',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/williamboman/mason.nvim',
  'https://github.com/hrsh7th/nvim-cmp',
  'https://github.com/hrsh7th/cmp-nvim-lsp',
  'https://github.com/hrsh7th/cmp-path',
  'https://github.com/hrsh7th/cmp-buffer',
  'https://github.com/windwp/nvim-autopairs',
  'https://github.com/lewis6991/gitsigns.nvim',
})

-- ==========================================================================
-- 3. PLUGIN CONFIGURATION
-- ==========================================================================

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = 'E',
      [vim.diagnostic.severity.WARN]  = 'W',
      [vim.diagnostic.severity.INFO]  = 'I',
      [vim.diagnostic.severity.HINT]  = 'H',
    },
  },
  virtual_text = true,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
})

local gitsigns_ok, gitsigns = pcall(require, 'gitsigns')
if gitsigns_ok then
  gitsigns.setup({
    signs = {
      add = { text = '┃' }, change = { text = '┃' },
      delete = { text = '_' }, topdelete = { text = '‾' },
      changedelete = { text = '~' }, untracked = { text = '┆' },
    },
    on_attach = function(bufnr)
      local map = function(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end
      map('n', ']c', function()
        if vim.wo.diff then vim.cmd.normal({ ']c', bang = true }) else gitsigns.nav_hunk('next') end
      end, 'Jump to next git change')
      map('n', '[c', function()
        if vim.wo.diff then vim.cmd.normal({ '[c', bang = true }) else gitsigns.nav_hunk('prev') end
      end, 'Jump to previous git change')
      map('n', '<leader>hp', gitsigns.preview_hunk, 'Git [H]unk [P]review')
      map('n', '<leader>hs', gitsigns.stage_hunk, 'Git [H]unk [S]tage')
      map('n', '<leader>hr', gitsigns.reset_hunk, 'Git [H]unk [R]eset')
    end,
  })
end

local treesitter_ok, treesitter_configs = pcall(require, 'nvim-treesitter.configs')
if treesitter_ok then
  treesitter_configs.setup({
    ensure_installed = {}, 
    auto_install = false,  
    sync_install = false,
    highlight = {
      enable = true,
      disable = function(lang, buf)
        -- POTATO PC TWEAK: Disable treesitter strictly on files > 50KB to prevent lag
        local max_filesize = 50 * 1024 
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

local autotag_ok, autotag = pcall(require, 'nvim-ts-autotag')
if autotag_ok then autotag.setup({ opts = { enable_close = true, enable_rename = true } }) end

local surround_ok, surround = pcall(require, 'mini.surround')
if surround_ok then surround.setup() end

local telescope_ok, telescope = pcall(require, 'telescope')
if telescope_ok then
  local previewers = require('telescope.previewers')
  local _bad_extensions = {
    'sqlite3', 'db', 'png', 'jpg', 'jpeg', 'gif', 'webp', 'pdf', 'zip', 'tar',
    'gz', '7z', 'rar', 'pyc', 'so', 'dylib', 'dll', 'woff', 'woff2', 'ttf',
    'eot', 'mp4', 'mp3', 'mkv', 'avi', 'mov', 'iso', 'bin', 'exe'
  }

  local safe_previewer_maker = function(filepath, bufnr, opts)
    opts = opts or {}
    filepath = vim.fn.expand(filepath)
    local ext = string.match(filepath, '%.([a-zA-Z0-9]+)$')
    if ext and vim.tbl_contains(_bad_extensions, string.lower(ext)) then return end

    local stat = (vim.uv or vim.loop).fs_stat(filepath)
    if not stat or stat.size > 100000 then return end -- Skip preview for >100KB

    previewers.buffer_previewer_maker(filepath, bufnr, opts)
  end

  telescope.setup({
    defaults = {
      buffer_previewer_maker = safe_previewer_maker,
      file_ignore_patterns = { '%.git/', 'node_modules/.*', '%.cache/.*' },
    }
  })

  local builtin_ok, builtin = pcall(require, 'telescope.builtin')
  if builtin_ok then
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
  end
end

-- ------------------------------------------------------------------------
-- LSP Configuration & Mason 
-- ------------------------------------------------------------------------
local mason_ok, mason = pcall(require, 'mason')
if mason_ok then
  mason.setup({
    ui = { check_outdated_packages_on_open = false } -- SECURITY & PERF: No background network calls on boot
  })
end

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

vim.lsp.config('lua_ls', { settings = { Lua = { diagnostics = { globals = { 'vim' } } } } })
vim.lsp.config('ts_ls', { settings = { typescript = { inlayHints = { includeInlayParameterNameHints = 'all' } } } })
vim.lsp.config('oxlint', { root_markers = { '.oxlintrc.json', 'package.json', '.git' }, workspace_required = false })
vim.lsp.config('tailwindcss', { filetypes = { 'html', 'css', 'javascriptreact', 'typescriptreact' } })
vim.lsp.config('html', {})
vim.lsp.config('cssls', {})
vim.lsp.config('jsonls', {})
vim.lsp.config('pyright', { settings = { python = { analysis = { autoSearchPaths = true, diagnosticMode = 'openFilesOnly' } } } })
vim.lsp.config('clangd', { filetypes = { 'c', 'cpp' }, cmd = { 'clangd', '--background-index' } })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('<leader>cd', vim.diagnostic.open_float, '[C]ode [D]iagnostic popup')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
  end,
})

-- ------------------------------------------------------------------------
-- Auto-completion: nvim-cmp
-- ------------------------------------------------------------------------
local cmp_ok, cmp = pcall(require, 'cmp')

if cmp_ok then
  cmp.setup({
    -- Use Neovim Native Snippet Engine (Requires Neovim v0.10+)
    snippet = { expand = function(args) vim.snippet.expand(args.body) end },
    mapping = cmp.mapping.preset.insert({
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-y>'] = cmp.mapping.confirm({ select = true }),
      ['<C-Space>'] = cmp.mapping.complete({}),
    }),
    sources = {
      { name = 'nvim_lsp' },
      { name = 'path' },
      { name = 'buffer', keyword_length = 3 },
    },
  })
end

local autopairs_ok, autopairs = pcall(require, 'nvim-autopairs')
if autopairs_ok then autopairs.setup({ check_ts = true }) end

-- ------------------------------------------------------------------------
-- Formatter: Prettier & Format-on-Save Integration
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
    if stat and stat.size > 50000 then 
      if not opts.silent then vim.notify('File too large for sync formatting', vim.log.levels.WARN) end
      return false
    end
  end

  local prettier = get_prettier_bin()
  if not prettier then return false end

  local args = { prettier, '--stdin-filepath', filepath ~= '' and filepath or 'dummy.' .. ft }
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local input = table.concat(lines, '\n')

  local res = vim.system(args, { stdin = input }):wait()
  if res.code == 0 and res.stdout and #res.stdout > 0 then
    local new_lines = vim.split(res.stdout, '\n', { plain = true })
    if #new_lines > 0 and new_lines[#new_lines] == '' then table.remove(new_lines, #new_lines) end
    if table.concat(lines, '\n') ~= table.concat(new_lines, '\n') then
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
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
      local oxlint_clients = vim.lsp.get_clients({ bufnr = event.buf, name = 'oxlint' })
      if #oxlint_clients > 0 then pcall(vim.cmd, 'silent! LspOxlintFixAll') end
      format_with_prettier({ bufnr = event.buf, silent = true })
    end
  end,
})
