---@diagnostic disable: undefined-global
local M = {}

---@class lspcategory lspclient object definition
---@field categories string[]

---@class lspclient lspclient object definition
---@field id integer
---@field name string
---@field version string
---@field offset_encoding string
---@field filetypes string
---@field initialization_options string
---@field categories lspcategory[]
---@field cmd string
---@field root_dir string
---@field attached string

---
--- get_init_client - クライアントの初期状態オブジェクトを取得
---
--- @param name string クライアント名
---
--- @return lspclient lspclient object definition list
---
M.get_init_client = function(name, cmd, root_dir)
  name = name or ""
  cmd = cmd or ""
  root_dir = root_dir or ""
  return {
    cid = 0,
    name = name,
    cmd = cmd,
    root_dir = root_dir,
    version = "",
    offset_encoding = "",
    filetypes = "",
    initialization_options = "",
    categories = {},
    attached = false,
  }
end

---
--- get_clients - クライアント取得
---
--- @return lspclient[] lspclient object definition list
---
M.get_clients = function()
  local clients = vim.lsp.get_clients()
  local bn = vim.api.nvim_get_current_buf()

  local all_clients = {}
  for _, client in pairs(clients) do
    local attached_buffer = client.attached_buffers[bn]
    local is_attached = attached_buffer ~= nil and attached_buffer == true
    local c = {
      cid = client.id,
      name = client.name,
      version = client.version,
      offset_encoding = client.offset_encoding,
      filetypes = client.filetypes,
      initialization_options = client.initialization_options,
      attached = is_attached,
    }

    all_clients[client.name] = c
  end

  return all_clients
end

return M
