-- Extra plugins for .NET / API development workflow

return {
  -- REST Client: run .http files directly from Neovim
  -- Usage: create a file with .http extension, write HTTP requests, use keymaps below.
  -- Supports environments, variables, and response inspection.
  {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    keys = {
      { "<leader>Rr", function() require("kulala").run() end,              desc = "Run HTTP Request" },
      { "<leader>Ra", function() require("kulala").run_all() end,          desc = "Run All Requests" },
      { "<leader>Rv", function() require("kulala").toggle_view() end,      desc = "Toggle Response View" },
      { "<leader>Re", function() require("kulala").set_selected_env() end, desc = "Set Environment" },
      { "<leader>Rc", function() require("kulala").copy() end,             desc = "Copy as cURL" },
    },
    opts = {
      default_view = "body",
      venv_filepath = ".env",
    },
  },
}
