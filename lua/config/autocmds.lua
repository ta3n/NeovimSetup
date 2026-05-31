-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable auto-format on save for C# files.
-- dotnet format loads the entire project on every save → blocks editing.
-- Use <leader>cf to format manually when needed.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "cs",
  callback = function()
    vim.b.autoformat = false
  end,
})

-- Workaround: nvim 0.12.x + csharp-ls returns inlay hints at positions that exceed
-- the line's byte length after UTF-16 → byte conversion, crashing nvim_buf_set_extmark.
-- Patch the handler to drop out-of-range hints before they are stored in bufstate.
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    local ih = vim.lsp.inlay_hint
    local orig = ih.on_inlayhint
    ih.on_inlayhint = function(err, result, ctx)
      if not err and result and ctx.bufnr and vim.api.nvim_buf_is_loaded(ctx.bufnr) then
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client then
          local lines = vim.api.nvim_buf_get_lines(ctx.bufnr, 0, -1, false)
          local filtered = {}
          for _, hint in ipairs(result) do
            local lnum = hint.position.line
            local line = lines[lnum + 1]
            if line then
              local byte_col =
                vim.str_byteindex(line, client.offset_encoding, hint.position.character, false)
              if byte_col <= #line then
                table.insert(filtered, hint)
              end
            end
          end
          result = filtered
        end
      end
      return orig(err, result, ctx)
    end
  end,
})

-- Refresh code lens for C# after entering a buffer or saving.
-- Shows "X references | X implementations" above methods, classes, properties.
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  pattern = "*.cs",
  callback = function()
    if vim.lsp.codelens then
      vim.lsp.codelens.refresh({ bufnr = 0 })
    end
  end,
})
