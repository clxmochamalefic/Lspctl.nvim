---@diagnostic disable: undefined-global
local M = {
  clients = {},
  bufnr = nil,
}

local function get_name()
  local line = vim.fn["getline"](".")

  local pos_first = string.find(line, "]", 0, true) or 0
  local pos_last = string.find(line, "(", 0, true) or 0

  local subs = string.sub(line, pos_first + 1, pos_last - 1)
  return string.gsub(subs, "%s+", "")
end

M.start = function()
  local name = get_name()
  local client = M.clients[name]
  if client then
    vim.print("[lspctl]start: " .. name)
    local config = {
      name = name,
      cmd = client.cmd,
      root_dir = client.root_dir,
    }
    vim.lsp.start(config, { bufnr = M.bufnr })
  end
  M.bufnr = nil
end

M.stop = function()
  local name = get_name()
  local client = M.clients[name]
  if client then
    vim.print("[lspctl]stop: " .. name)
    vim.lsp.stop_client(client.id)
  end
  M.bufnr = nil
end

M.restart = function()
  local name = get_name()
  vim.print("[lspctl]restart: " .. name)
  local client = M.clients[name]
  if client then
    vim.lsp.stop_client(client.id)
    --vim.lsp.start_client(name)
    local config = {
      name = name,
      cmd = client.cmd,
      root_dir = client.root_dir,
    }
    vim.lsp.start(config, { bufnr = M.bufnr })
  end
  M.bufnr = nil
end

return M
