# easy-dotnet.nvim Integration Design

**Date:** 2026-05-31
**Status:** Approved

## Context

LazyVim config on macOS Apple Silicon, Neovim 0.12.2. LSP is `csharp-ls` (Roslyn/omnisharp explicitly blocked). Formatter is `dotnet format` via conform.nvim. Completion via blink.cmp. Snacks.nvim available via LazyVim.

## Goal

Integrate `GustavEikaas/easy-dotnet.nvim` for .NET project management: run, build, test, debug, NuGet packages, EF migrations. Single new file `lua/plugins/easy-dotnet.lua`. No changes to `csharp.lua`.

## Approach: Full integration (Approach B)

Three spec entries in one file:
1. `easy-dotnet.nvim` — main plugin
2. `lualine.nvim` — opts patch for active_project + jobs
3. `which-key.nvim` — group labels for `<leader>n` and `<leader>ne`

## LSP Safety

Both LSP features disabled to prevent conflict with `csharp-ls`:
- `lsp.enabled = false` — prevents Roslyn LSP from starting
- `projx_lsp.enabled = false` — prevents .csproj autocomplete LSP

## Lazy Loading

`ft = { "cs", "csproj", "sln" }` plus `keys` entries both act as load triggers.

## Keymap Prefix: `<leader>n` (dotNet)

`<leader>d` is reserved for LazyVim's nvim-dap (breakpoints, continue, etc.).

| Key | Action |
|-----|--------|
| `<leader>nr/R` | Run / Run default |
| `<leader>nw/W` | Watch / Watch default |
| `<leader>nb/B` | Build / Build solution |
| `<leader>nq` | Build + quickfix |
| `<leader>nt/T` | Test / Test solution |
| `<leader>nX` | Test runner toggle |
| `<leader>nd/D` | Debug / Debug default |
| `<leader>np/P` | Add / Remove NuGet package |
| `<leader>no` | Outdated packages |
| `<leader>ns` | User secrets |
| `<leader>nc` | Clean |
| `<leader>nx` | Restore |
| `<leader>nea/r/l` | EF: add / remove / list migrations |
| `<leader>neu/U/d` | EF: update DB / update to / drop DB |

## Lualine

Lualine components wrapped with lazy `require` + `cond` guard so they only render when easy-dotnet is loaded (i.e., a .cs file is open). Appended to `lualine_x`.

## Dependencies

- `nvim-lua/plenary.nvim` (easy-dotnet runtime dep)
- `mfussenegger/nvim-dap` (DAP integration, auto-registered)

## Required Global Tools

```sh
dotnet tool install -g EasyDotnet       # required
dotnet tool install --global dotnet-ef  # for EF commands
```

netcoredbg must be installed separately for step-through debugging:
```sh
brew install netcoredbg  # or download from GitHub releases
```
