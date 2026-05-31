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

-- Code lens inline display: convert virt_lines (separate line above) → virt_text (eol, same line).
-- Default nvim rendering puts code lens on its own virtual line above the code, which looks
-- misaligned. This patches it to show inline at the end of the declaration line instead.
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    local pending = {}

    local function get_codelens_namespaces()
      local result = {}
      for name, ns_id in pairs(vim.api.nvim_get_namespaces()) do
        if name:match("^nvim%.lsp%.codelens:") then
          result[ns_id] = true
        end
      end
      return result
    end

    local function convert_to_eol(bufnr)
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      for ns_id in pairs(get_codelens_namespaces()) do
        local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns_id, 0, -1, { details = true })
        for _, mark in ipairs(marks) do
          local id, row, _, details = mark[1], mark[2], mark[3], mark[4]
          if details.virt_lines then
            local virt_text = {}
            for _, vl in ipairs(details.virt_lines) do
              for _, chunk in ipairs(vl) do
                if chunk[1] ~= "" then
                  table.insert(virt_text, chunk)
                end
              end
            end
            if #virt_text > 0 then
              vim.api.nvim_buf_del_extmark(bufnr, ns_id, id)
              vim.api.nvim_buf_set_extmark(bufnr, ns_id, row, 0, {
                virt_text = { { "  ", "LspCodeLensSeparator" }, unpack(virt_text) },
                virt_text_pos = "eol",
                hl_mode = "combine",
              })
            end
          end
        end
      end
    end

    local ns = vim.api.nvim_create_namespace("custom.codelens.inline")
    vim.api.nvim_set_decoration_provider(ns, {
      on_win = function(_, _, bufnr, _, _)
        if vim.bo[bufnr].filetype ~= "cs" then
          return
        end
        if pending[bufnr] then
          return
        end
        pending[bufnr] = true
        vim.schedule(function()
          pending[bufnr] = nil
          convert_to_eol(bufnr)
        end)
      end,
    })
  end,
})
