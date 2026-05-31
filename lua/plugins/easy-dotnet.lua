-- .NET project management: run / build / test / debug / NuGet / EF migrations
-- Requirements:
--   dotnet tool install -g EasyDotnet
--   dotnet tool install --global dotnet-ef   (EF commands)
--   netcoredbg (DAP step-through): brew install netcoredbg
--
-- LSP: lsp.enabled=false + projx_lsp.enabled=false → Roslyn never starts,
-- csharp-ls (csharp.lua) remains the sole language server.
-- Keymaps: <leader>n (dotNet) — avoids conflict with <leader>d (LazyVim DAP).

return {
  -- 1. Main plugin ─────────────────────────────────────────────────────────
  {
    "GustavEikaas/easy-dotnet.nvim",
    ft = { "cs", "csproj", "sln" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap",
    },
    keys = {
      -- Run
      { "<leader>nr", function() require("easy-dotnet").run() end,           desc = "Run" },
      { "<leader>nR", function() require("easy-dotnet").run_default() end,   desc = "Run default" },
      { "<leader>nw", function() require("easy-dotnet").watch() end,         desc = "Watch" },
      { "<leader>nW", function() require("easy-dotnet").watch_default() end, desc = "Watch default" },
      -- Build
      { "<leader>nb", function() require("easy-dotnet").build() end,                  desc = "Build" },
      { "<leader>nB", function() require("easy-dotnet").build_solution() end,         desc = "Build solution" },
      { "<leader>nq", function() require("easy-dotnet").build_quickfix() end,         desc = "Build (quickfix)" },
      -- Test
      { "<leader>nt", function() require("easy-dotnet").test() end,          desc = "Test" },
      { "<leader>nT", function() require("easy-dotnet").test_solution() end, desc = "Test solution" },
      { "<leader>nX", function() require("easy-dotnet").testrunner() end,    desc = "Test runner" },
      -- Debug
      { "<leader>nd", function() require("easy-dotnet").debug() end,         desc = "Debug" },
      { "<leader>nD", function() require("easy-dotnet").debug_default() end, desc = "Debug default" },
      -- Packages
      { "<leader>np", function() require("easy-dotnet").add_package() end,    desc = "Add NuGet package" },
      { "<leader>nP", function() require("easy-dotnet").remove_package() end, desc = "Remove package" },
      { "<leader>no", function() require("easy-dotnet").outdated() end,       desc = "Outdated packages" },
      -- Utilities
      { "<leader>ns", function() require("easy-dotnet").secrets() end, desc = "User secrets" },
      { "<leader>nc", function() require("easy-dotnet").clean() end,   desc = "Clean" },
      { "<leader>nx", function() require("easy-dotnet").restore() end, desc = "Restore" },
      -- EF migrations
      { "<leader>nea", function() require("easy-dotnet").ef_migrations_add() end,       desc = "Add migration" },
      { "<leader>ner", function() require("easy-dotnet").ef_migrations_remove() end,    desc = "Remove last migration" },
      { "<leader>nel", function() require("easy-dotnet").ef_migrations_list() end,      desc = "List migrations" },
      { "<leader>neu", function() require("easy-dotnet").ef_database_update() end,      desc = "Update database" },
      { "<leader>neU", function() require("easy-dotnet").ef_database_update_pick() end, desc = "Update database (pick)" },
      { "<leader>ned", function() require("easy-dotnet").ef_database_drop() end,        desc = "Drop database" },
    },
    opts = {
      -- Disable both LSP integrations — csharp-ls is the sole server (see csharp.lua).
      lsp = { enabled = false },
      projx_lsp = { enabled = false },
      picker = "snacks",
      debugger = {
        auto_register_dap = true,
        console = "integratedTerminal",
      },
      test_runner = {
        viewmode = "float",
      },
    },
  },

  -- 2. Lualine: active project name + background job spinner ───────────────
  -- Components are lazily required and hidden when easy-dotnet is not loaded.
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections = opts.sections or {}
      opts.sections.lualine_x = opts.sections.lualine_x or {}
      table.insert(opts.sections.lualine_x, {
        function() return require("easy-dotnet").lualine.active_project() end,
        cond = function() return package.loaded["easy-dotnet"] ~= nil end,
      })
      table.insert(opts.sections.lualine_x, {
        function() return require("easy-dotnet").lualine.jobs() end,
        cond = function() return package.loaded["easy-dotnet"] ~= nil end,
      })
    end,
  },

  -- 3. which-key: group labels for the <leader>n prefix tree ───────────────
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>n",  group = "dotNet" },
        { "<leader>ne", group = "EF migrations" },
      },
    },
  },

  -- 4. Snacks explorer: press "A" on a directory to scaffold a .NET file ───
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            win = {
              list = {
                keys = { ["A"] = "explorer_add_dotnet" },
              },
            },
            actions = {
              explorer_add_dotnet = function(picker)
                local dir = picker:dir()
                require("easy-dotnet").create_new_item(dir, function(item_path)
                  local tree = require("snacks.explorer.tree")
                  local actions = require("snacks.explorer.actions")
                  tree:open(dir)
                  tree:refresh(dir)
                  actions.update(picker, { target = item_path })
                  picker:focus()
                end)
              end,
            },
          },
        },
      },
    },
  },
}
