-- AI CLI tools: Claude Code + OpenAI Codex
-- Opens each tool as a floating terminal in the project root.
-- Toggle: same keymap opens/closes the terminal.

return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>aC",
        function()
          Snacks.terminal("claude", { cwd = LazyVim.root() })
        end,
        desc = "Claude Code",
      },
      {
        "<leader>aO",
        function()
          Snacks.terminal("codex", { cwd = LazyVim.root() })
        end,
        desc = "OpenAI Codex",
      },
    },
  },
}
