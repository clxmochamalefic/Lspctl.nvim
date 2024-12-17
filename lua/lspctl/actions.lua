---@diagnostic disable: undefined-global
local M = {
  clients = {}
}

local function get_name()
  --vim.print(M.clients)
  return vim.fn["getline"](".")
end

function M:start()
  local name = get_name()
  if M.clients[name] then
    --vim.print("start")
    vim.print(name)
    vim.lsp.start_client(name)
  end
end

function M:stop()
  local name = get_name()
  local client = M.clients[name]
  if client then
    vim.print("stop")
    vim.lsp.stop_client(client.id)
  end
end

function M:restart()
  local name = get_name()
  if M.clients[name] then
    --vim.print("restart")
    vim.lsp.restart(name)
  end
end

return M
