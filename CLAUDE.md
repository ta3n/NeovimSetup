# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

LazyVim-based Neovim configuration targeting .NET/C# development on macOS (Apple Silicon). Built on the [LazyVim](https://lazyvim.github.io) starter template with a focused set of custom plugins.

## Architecture

Entry point is `init.lua`, which bootstraps lazy.nvim and loads everything via `config.lazy`.

**`lua/config/`** — loaded automatically by LazyVim at startup:
- `lazy.lua` — plugin manager bootstrap and spec; imports all files under `lua/plugins/`
- `options.lua` — editor options (extend LazyVim defaults)
- `keymaps.lua` — key bindings (extend LazyVim defaults)
- `autocmds.lua` — autocommands; currently disables auto-format-on-save for C# (dotnet format is slow) and auto-refreshes code lens on `.cs` files

**`lua/plugins/`** — each file returns a lazy.nvim plugin spec array:
- `csharp.lua` — C# IDE setup: treesitter `c_sharp`, `csharp-ls` LSP with codelens + inlay hints, blink.cmp completion with auto-import, `dotnet format` formatter via conform.nvim; also blocks omnisharp to prevent CPU conflicts
- `extras.lua` — extra workflow plugins: kulala.nvim for running `.http` REST files (`<leader>R*`)
- `example.lua` — **inactive template** (guarded by `if true then return {} end`), kept as reference

**`lazyvim.json`** — tracks which LazyVim extras are enabled (currently none enabled via the extras system).

## Lua Formatting

StyLua is the formatter for all `.lua` files:
- 2-space indentation, 120-column width (see `stylua.toml`)
- Run: `stylua lua/`

## C# / .NET Setup

Requirements:
```sh
dotnet tool install --global csharp-ls
# PATH must include: $HOME/.dotnet/tools  (already set in ~/.zshrc)
```

- LSP: `csharp-ls` (not omnisharp — omnisharp is explicitly blocked to avoid running both)
- Auto-format on save is **disabled** for C#; use `<leader>cf` to format manually
- Code lens refresh happens automatically on `BufEnter`, `BufWritePost`, `InsertLeave`

## Adding Plugins

Add a new file under `lua/plugins/` returning a lazy.nvim spec, or add entries to an existing file. LazyVim merges plugin specs via `opts` tables — use `opts = function(_, opts)` to extend existing plugin configs rather than replacing them.
