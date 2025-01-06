local M = {}

-- Trim leading and ending white space from a string
-- @param s string: The string to be trim
-- @return string: The trimmed string
local function trim_string(s)
  -- ? Is this validation necessary?
  if type(s) ~= "string" then
    error("trim_string: Expected a string, got " .. type(s))
  end
  return s:match("^%s*(.-)%s*$")
end

function M.setup()
  -- Support for .http and .rest files
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.http", "*.rest" },
    callback = function()
      vim.bo.filetype = "http"
    end,
  })
end

function M.run()
  -- Read the current buffer
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- Combine lines into a single command
  local request = table.concat(lines, "\n")

  -- Handle line continuations (`\`) and trim excess whitespace
  request = request:gsub("\\%s*\n", " "):gsub("\n", " ")
  request = trim_string(request)

  -- Add the '-s' flag if not present
  if not request:find("%-s") then
    request = request .. " -s"
  end

  -- Execute the curl command
  local output = vim.fn.systemlist(request)

  -- Open a new vertical split and display the output
  vim.api.nvim_command("vsplit")
  local bfrnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, bfrnr)
  vim.api.nvim_buf_set_lines(bfrnr, 0, -1, false, output)
end

return M
