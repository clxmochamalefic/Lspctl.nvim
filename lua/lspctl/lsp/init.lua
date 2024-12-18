local util = require('lspctl.lsp.util')

local M = {
  clients = nil,
  categories = {},

  lspconfig = require('lspctl.lsp.lspconfig'),
  mason = require('lspctl.lsp.mason'),
}

--- @class get_client_opts
--- @field manager "lspconfig"|"mason"

---
--- get_all_clients - クライアント取得
---
--- @param opt get_client_opts
---
--- @return lspclient[] lspclient object definition list
---
M.get_all_clients = function(opt)
  opt = opt or { manager = 'lspconfig' }
  if not M.clients then
    -- get installed LSP server list from each configs
    -- インストール済みサーバー一覧を取得
    if opt.manager == 'lspconfig' then
      local clients = M.lspconfig()
      M.clients = clients
    elseif opt.manager == 'mason' then
      local clients = M.mason()
      M.clients = clients
    end
  end

  -- update active servers / アクティブなサーバーを更新
  local active_clients = util.get_clients()
  for name, client in pairs(active_clients) do
    local categories = M.clients[name]
    client.categories = categories
    M.clients[name] = client
  end

  return M.clients
end

return M
