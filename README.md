<div align="center">

# ⚡ Native Neovim 0.12+ Config

<p align="center">
  <b>A lightning-fast, zero-dependency, single-file IDE configuration built natively for Neovim 0.12+</b>
</p>

[![Neovim](https://img.shields.io/badge/Neovim-0.12%2B-76B900?style=for-the-badge&logo=neovim&logoColor=white)](https://neovim.io/)
[![Lua](https://img.shields.io/badge/Lua-5.1%2FNeovim-000080?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org/)
[![Theme](https://img.shields.io/badge/Theme-Tokyo%20Night%20Moon-7aa2f7?style=for-the-badge&logo=visualstudiocode&logoColor=white)](https://github.com/folke/tokyonight.nvim)
[![Plugin Manager](https://img.shields.io/badge/Plugin%20Manager-Native%20vim.pack-ff9e64?style=for-the-badge)](https://neovim.io/doc/user/repeat.html#vim.pack)

---

### 📸 Preview

![Neovim Workspace Preview](assets/nvim_main_preview.jpg)

<br/>

![Telescope Fuzzy Finder Preview](assets/nvim_telescope_preview.jpg)

</div>

---

## ✨ Features

- **🚀 Zero-Dependency Bootstrap:** Powered by Neovim's brand new built-in `vim.pack.add` API — no third-party package managers (Lazy/Packer/Plug) required.
- **📄 Single File Architecture:** Everything is cleanly organized inside a single, transparent [`init.lua`](file:///home/ajinkya/.config/nvim/init.lua).
- **🎨 Modern Aesthetics:** [Tokyo Night (Moon)](https://github.com/folke/tokyonight.nvim) theme paired with [mini.icons](https://github.com/echasnovski/mini.icons) & [mini.statusline](https://github.com/echasnovski/mini.statusline) rendering mode icons (`󰋜 NORMAL`, `󰏫 INSERT`, `󰈈 VISUAL`, `󰞷 COMMAND`, ` TERMINAL`).
- **💡 Keymap Helper Popup:** [which-key.nvim](https://github.com/folke/which-key.nvim) interactive popup helper for discovering leader keybindings on the fly.
- **🌿 Git Integration:** [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) for gutter change indicators, hunk navigation (`]c`/`[c`), line blame popups, and hunk previews.
- **🔍 Fast Fuzzy Finding:** [Telescope](https://github.com/nvim-telescope/telescope.nvim) configured to find files, live grep text (including hidden files), search help, and switch buffers.
- **⚡ Native Treesitter & LSP:** Built-in Neovim 0.12 Treesitter syntax parsing + [Mason](https://github.com/williamboman/mason.nvim) LSP integration with custom diagnostic signs (`󰅚` Error, `󰀦` Warn, `󰋼` Info, `󰌵` Hint) and `--query-driver` support for C/C++ (`clangd`).
- **⌨️ Intelligent Autocompletion:** [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) with LuaSnip snippet engine, LSP sources, path completion, and auto-pairing (`nvim-autopairs`).

---

## 📋 Requirements

| Dependency | Minimum Version | Description |
| :--- | :--- | :--- |
| **Neovim** | `≥ 0.12.0` | Strict requirement for `vim.pack` & native Treesitter |
| **Git** | Any modern version | Required by `vim.pack` for auto-cloning plugins |
| **Ripgrep (`rg`)** | Any | Required by Telescope for live text searching |
| **fd** | Recommended | Accelerated file searching for Telescope |
| **Nerd Font** | Recommended | Enables statusline mode icons & filetype glyphs |

---

## 🚀 Quick Start

1. **Backup your existing config:**
   ```bash
   mv ~/.config/nvim ~/.config/nvim.bak
   ```

2. **Clone this repository into `~/.config/nvim`:**
   ```bash
   git clone https://github.com/AMSearth/Latest_Neovim_config.git ~/.config/nvim
   ```

3. **Launch Neovim:**
   ```bash
   nvim
   ```
   *Neovim will automatically clone and load all missing plugins on first boot!*

---

## ⌨️ Keybindings

The `<Leader>` key is set to **`<Space>`**.

### 🪟 Navigation & General

| Keybinding | Action | Mode |
| :--- | :--- | :--- |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | Move focus to Left / Down / Up / Right window split | Normal |
| `<Esc>` | Clear search highlights | Normal |
| `<Space> q` | Open Diagnostic Quickfix List | Normal |

### 🔍 Telescope (Fuzzy Search)

| Keybinding | Action | Mode |
| :--- | :--- | :--- |
| `<Space> s f` | Search Files (includes hidden files, ignores `.git`) | Normal |
| `<Space> s g` | Live Grep / Search Text across project | Normal |
| `<Space> s w` | Search word under cursor | Normal |
| `<Space> s h` | Search Help Tags | Normal |
| `<Space> s k` | Search Keymaps | Normal |
| `<Space> s d` | Search Workspace Diagnostics | Normal |
| `<Space> <Space>` | Switch between open buffers | Normal |

### 🧠 LSP & Code Tools

| Keybinding | Action | Mode |
| :--- | :--- | :--- |
| `g d` | Go to Definition | Normal |
| `g r` | Go to References | Normal |
| `g I` | Go to Implementation | Normal |
| `K` | Display Hover Documentation | Normal |
| `<Space> r n` | Rename Symbol | Normal |
| `<Space> c a` | Code Action | Normal |

### 🌿 Git Hunks (`gitsigns`)

| Keybinding | Action | Mode |
| :--- | :--- | :--- |
| `]c` / `[c` | Jump to Next / Previous Git Hunk | Normal |
| `<Space> h p` | Preview Git Hunk | Normal |
| `<Space> h b` | Toggle Line Blame | Normal |
| `<Space> h s` | Stage Git Hunk | Normal |
| `<Space> h r` | Reset Git Hunk | Normal |

---

## 📁 File Structure

```
~/.config/nvim/
├── init.lua              # Complete single-file Neovim configuration
├── nvim-pack-lock.json   # Lockfile specifying exact Git commit SHAs for vim.pack
├── assets/               # README preview screenshots
├── README.md             # Project documentation
└── .gitignore            # Git ignore rules
```

---

<div align="center">
  <sub>Built with ❤️ for Neovim 0.12+</sub>
</div>



