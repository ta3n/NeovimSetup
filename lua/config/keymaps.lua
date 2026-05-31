-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Always focus the explorer instead of toggling it closed.
-- Snacks.picker internals: if explorer is open, pick() calls current:close().
-- Instead: get the live picker and focus it, or open fresh if not present.
vim.keymap.set("n", "<leader>e", function()
  local explorer = Snacks.picker.get({ source = "explorer" })[1]
  if explorer then
    explorer:focus()
  else
    Snacks.explorer.open()
  end
end, { desc = "Explorer (focus)", silent = true })
