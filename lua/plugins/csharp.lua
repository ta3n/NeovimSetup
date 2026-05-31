-- C# / .NET development support
-- Requirements:
--   csharp-ls: dotnet tool install --global csharp-ls
--   PATH:      export PATH="$PATH:$HOME/.dotnet/tools"  (already in ~/.zshrc)
--
-- Formatter (dotnet format) runs per-file from the nearest .sln/.csproj root.
-- To use CSharpier instead: dotnet tool install --global csharpier
--   then swap formatter entry to { "csharpier" } and configure below.

return {
  -- 1. Treesitter: C# syntax highlighting + indentation
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, { "c_sharp" })
    end,
  },

  -- 2. LSP: csharp-ls
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Code lens: hiện "X references | X implementations" trên method/class/property.
      -- Refresh tự động khi mở file hoặc sau khi lưu (xem autocmds.lua).
      codelens = { enabled = true },
      -- Inlay hints: hiện parameter names và return types inline.
      inlay_hints = { enabled = true },
      servers = {
        csharp_ls = {
          cmd = { "csharp-ls" },
          filetypes = { "cs" },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("*.sln", "*.csproj", ".git")(fname)
          end,
          -- Debounce: wait 500ms after typing before sending to LSP (reduces CPU spikes)
          flags = {
            debounce_text_changes = 500,
          },
        },
      },
      setup = {
        csharp_ls = function(server, opts)
          require("lspconfig")[server].setup(opts)
          return true
        end,
        -- Disable omnisharp — mason may have installed it; running both = 100% CPU.
        omnisharp = function() return true end,
        omnisharp_mono = function() return true end,
      },
    },
  },

  -- 3. Completion: Ctrl+Space để trigger manually + auto-import using namespace.
  --    blink.cmp áp dụng additionalTextEdits từ LSP khi accept → tự add `using`.
  --    Nếu gõ tên class chưa import: accept suggestion → using tự thêm vào đầu file.
  --    Hoặc dùng <leader>ca (code action) → "Add using for ..."
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      completion = {
        -- Accept completion item và apply additionalTextEdits (thêm using namespace)
        accept = { auto_brackets = { enabled = true } },
        list = { selection = { preselect = true, auto_insert = false } },
      },
    },
  },

  -- 3. Formatter: dotnet format
  --    Runs from the nearest .sln/.csproj directory.
  --    Disable auto-format on save if your team hasn't aligned on this yet —
  --    comment out the format_on_save block in your options.lua.
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        cs = { "dotnet_format" },
      },
      formatters = {
        dotnet_format = {
          command = "dotnet",
          args = { "format", "--include", "$FILENAME", "--no-restore" },
          -- Walk up from the file to find the nearest .sln or .csproj
          cwd = function(_, ctx)
            return vim.fs.root(ctx.dirname, function(name)
              return name:match("%.sln$") ~= nil or name:match("%.csproj$") ~= nil
            end) or ctx.dirname
          end,
          stdin = false,
          require_cwd = true,
        },
        -- Optional: CSharpier (uncomment + swap formatters_by_ft above to use)
        -- Requires: dotnet tool install --global csharpier
        -- csharpier = {
        --   command = "dotnet-csharpier",
        --   args = { "--write-stdout" },
        --   stdin = true,
        -- },
      },
    },
  },
}
