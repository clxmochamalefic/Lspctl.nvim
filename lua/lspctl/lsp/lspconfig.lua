---@diagnostic disable: undefined-global
local util = require('lspctl.lsp.util')

---
--- get all installed LSP servers
--- インストール済みのLSPサーバーを取得
---
--- @return lspclient[] lspclient object definition list
---
return function()
  local success, lspconfig = pcall(require, 'lspconfig')
  if not success then
    return {}
  end

  -- インストール済みLSPの一覧を取得する
  local installed_servers = {}
  for name, conf in pairs(lspconfig) do
    local default_config = conf.config_def.default_config
    local client = util.get_init_client(name, name, default_config.cmd, default_config.root_dir())
    installed_servers[name] = client
  end

  return installed_servers
end
