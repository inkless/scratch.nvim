local fn = vim.fn
local create_cmd = vim.api.nvim_create_user_command

local M = {}

M.options = {
  scratch_name = "__Scratch__",
  position = "botright",
  height = 0.2,
}

function M.open_window(set_focus)
  local options = M.options
  local scratch_bufnr = fn.bufnr(options.scratch_name)

  if scratch_bufnr == -1 then
    vim.cmd(options.position .. " " ..  M.get_size() .. " new " .. options.scratch_name)

    vim.bo.bufhidden = "hide"
    vim.bo.buflisted = false
    vim.bo.buftype = "nofile"

    -- activate autocmds
  else
    local scratch_winnr = fn.bufwinnr(scratch_bufnr)
    if scratch_winnr == -1 then
      vim.cmd(options.position .. " " ..  M.get_size() .. " split +buffer" .. scratch_bufnr)
    else
      if fn.winnr() ~= scratch_winnr and set_focus then
        vim.cmd(scratch_winnr .. " wincmd w")
      end
    end
  end
end

function M.get_size()
  if M.options.height < 1 then
    return math.floor(fn.winheight(0) * M.options.height)
  else
    return math.floor(M.options.height)
  end
end

function M.open(reset)
  M.open_window(true)

  if reset then
    fn.execute("%d _", "silent")
  else
    fn.execute("normal! G$", "silent")
  end
end

function M.open_with_insert(reset)
  M.open(reset)

  vim.cmd("startinsert!")
end

function M.open_with_selection_pasted()
  print("todo")
end

function M.toggle_preview()
  local scratch_winnr = fn.bufwinnr("__Scratch__")
  if scratch_winnr ~= -1 then
    vim.cmd(scratch_winnr .. " close")
  else
    M.open_window(false)
  end
end

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts)

  create_cmd("ScratchTogglePreview", M.toggle_preview, {})
  create_cmd("Scratch", M.open, {})
  create_cmd("ScratchInsert", M.open_with_insert, {})
end

return M
