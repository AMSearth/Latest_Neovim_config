# 🚀 Native Neovim Config (0.12+)

A lightning-fast, cutting-edge, single-file Neovim configuration built exclusively for **Neovim 0.12+**. 

This setup ditches third-party package managers (like Lazy, Packer, or Plug) in favor of Neovim's brand new native `vim.pack` functionality. It provides a fully functional, IDE-like experience out of the box while remaining lightweight and completely transparent.

## ✨ Features

* **Zero-Dependency Bootstrap:** Uses native `vim.pack.add` to clone and load plugins directly via Git.
* **Single File:** Everything is contained within a single `init.lua` file.
* **Aesthetics:** [Tokyo Night (Moon)](https://github.com/folke/tokyonight.nvim) theme enabled by default.
* **Fuzzy Finding:** [Telescope](https://github.com/nvim-telescope/telescope.nvim) configured for lightning-fast file and text searching.
* **Syntax Highlighting:** Leverages Neovim 0.12's native Treesitter parsing (no third-party TS plugin required!).
* **Intelligent Auto-completion:** [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) integrated with LuaSnip and LSP sources.
* **LSP & Tooling:** [Mason](https://github.com/williamboman/mason.nvim) and `mason-lspconfig` (v2.0+) natively integrated via the new `vim.lsp.config` API for zero-friction language server setups.

## 📋 Requirements

* **Neovim 0.12.0** or newer (Strict requirement for `vim.pack` and native Treesitter).
* **Git** (for cloning plugins).
* **Ripgrep (`rg`)** (Required for Telescope live grep).
* **fd** (Recommended for Telescope file finding).
* A **Nerd Font** (Optional, but recommended for icons).

## 🚀 Installation

1. **Backup your existing config:**
   ```bash
   mv ~/.config/nvim ~/.config/nvim.bak
