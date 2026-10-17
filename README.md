# 🥔 Neovim "Potato PC" Edition (v0.11+ Native)

Welcome to your lightning-fast, ultra-optimized Neovim configuration. This setup was meticulously engineered to run on low-spec hardware without sacrificing the modern "IDE" experience. 

By utilizing Neovim's bleeding-edge **v0.11+ Native LSP API**, we have entirely bypassed heavy package managers (like Lazy, Packer, or Mason) and bloated UI plugins.

## ✨ Core Features
* **Zero Package Managers:** Plugins are loaded instantly using Neovim's native `vim.pack.add` cache.
* **No Mason or lspconfig:** Language servers are executed directly from your Windows PATH using the new C-based `vim.lsp.config` API, completely eliminating background network requests and heavy Lua parsing on startup.
* **Native Explorer & Theme:** Uses Neovim's built-in `Netrw` (configured as a sidebar) and the native `habamax` theme with a custom transparent background patch.
* **Aggressive Performance Tweaks:** 
  * Capped `shada` file size to prevent history bloat.
  * Strict `50KB` file size limit for Treesitter and Prettier to prevent CPU lockups.
  * Swapfiles and legacy Vim providers (Ruby, Perl, Node) disabled.
* **Smart Prettier Integration:** A custom, synchronous formatting script that natively formats code on save without requiring a dedicated formatting plugin.

---

## ⌨️ Keybindings Cheat Sheet

The `<leader>` key is mapped to **Space**.

### General & Navigation
| Keybind | Action |
| :--- | :--- |
| `<leader>e` | Toggle File Explorer (Netrw Sidebar) |
| `<Esc>` | Clear search highlights (Normal mode) |
| `<C-h/j/k/l>` | Move focus left/down/up/right between window splits |
| `q` | Instantly close helper windows (Help, Netrw, Diagnostics) |
| `<Esc><Esc>` | Exit Terminal mode |

### Visual Mode (Selecting Text)
| Keybind | Action |
| :--- | :--- |
| `<` or `>` | Indent text left or right (keeps text selected) |
| `J` or `K` | Move the selected block of text down or up |

### Search (Telescope)
| Keybind | Action |
| :--- | :--- |
| `<leader>sf` | Search Files (Fuzzy find) |
| `<leader>sg` | Search by Grep (Search for text inside files) |

### Git (Gitsigns)
| Keybind | Action |
| :--- | :--- |
| `]c` / `[c` | Jump to next / previous Git change (hunk) |
| `<leader>hp` | Preview Git hunk (floating window) |
| `<leader>hs` | Stage Git hunk |
| `<leader>hr` | Reset (undo) Git hunk |

### LSP & Code Diagnostics
| Keybind | Action |
| :--- | :--- |
| `gd` | Go to Definition |
| `gr` | Go to References |
| `K` | Hover Documentation |
| `<leader>rn` | Rename variable/symbol across file |
| `<leader>ca` | Code Action (Auto-fix suggestions) |
| `<leader>cd` | Show Code Diagnostic (Error) in floating window |
| `]d` / `[d` | Jump to next / previous diagnostic error |

### Formatting
| Keybind | Action |
| :--- | :--- |
| `<leader>cp` | Code Prettier Format (Force format current buffer) |
| `<leader>tp` | Toggle Auto-format on save (ON/OFF) |

### Autocomplete (Insert Mode)
| Keybind | Action |
| :--- | :--- |
| `<C-n>` | Next suggestion |
| `<C-p>` | Previous suggestion |
| `<C-y>` | Confirm/Accept suggestion |

---

## 🛠️ Tooling Guide: How to Install and Add LSPs

Because this configuration removes `Mason`, Neovim will no longer download Language Servers (LSPs) for you. You must install them globally on your operating system.

### Step 1: Install the Executable Globally
Open PowerShell and use a package manager like `npm` (Node.js) or `winget` to install the language server.

**Popular Servers via NPM:**
```powershell
# Web Development (HTML, CSS, JSON)
npm install -g vscode-langservers-extracted

# Python
npm install -g pyright

# TypeScript / JavaScript
npm install -g typescript typescript-language-server

# Prettier (Formatter)
npm install -g prettier
```

**Popular Servers via Winget/System:**
```powershell
# C / C++ (Installs LLVM which includes clangd)
winget install LLVM

# Lua
winget install lua-language-server
```

### Step 2: Configure it in `init.lua`
Once installed on your PC, you need to tell Neovim to look for it. Scroll to **Section 9** in your `init.lua` and use this exact template:

```lua
vim.lsp.config('server_name', {
  cmd = { 'executable-name', '--stdio' }, -- Check server docs for required flags
  filetypes = { 'language_extension' },
})

-- The Failsafe: Only start it if Windows can find the executable!
if vim.fn.executable('executable-name') == 1 then 
  vim.lsp.enable('server_name') 
end
```

**Example (Adding Go Support):**
If you ran `go install golang.org/x/tools/gopls@latest`, you would add this to your config:
```lua
vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
})
if vim.fn.executable('gopls') == 1 then vim.lsp.enable('gopls') end
```

---

## 🏗️ Architecture: Understanding Your `init.lua`

Your `init.lua` is structured in sequential blocks to maximize load speeds:

1. **Bytecode Cache:** `vim.loader.enable()` compiles your Lua code into bytecode on the first run, shaving off milliseconds on future boots.
2. **Performance Flags:** Explicitly disables legacy integrations and caps history files before the UI even begins drawing.
3. **Theme Override:** Hijacks the native `habamax` theme *before* it fully loads to strip the background colors, letting your terminal's transparency shine through while keeping floating windows (like autocomplete) solid and readable.
4. **Plugin `pack.add`:** Uses Neovim's native package API to grab URLs directly. When Neovim detects a missing URL on startup, it quietly clones it in the background to your local `pack` folder.
5. **v0.11 LSP API:** Leverages `vim.lsp.config` (replacing the deprecated `nvim-lspconfig` plugin) alongside a custom `vim.fn.executable()` check. This acts as a circuit-breaker: if a server isn't installed, Neovim ignores it instead of throwing a fatal crash.
