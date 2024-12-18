---@diagnostic disable: undefined-global
local util = require('lspctl.lsp.util')

local function get_mason_category_map()
  local success, registry = pcall(require, 'mason-registry')
  if not success then
    return {}
  end

  local installed_packages = registry.get_installed_packages()

  local packages = {}
  for _, fullname in ipairs(installed_packages) do
    --packages[name] = util.get_init_client(name)
    --packages[name].categories = package.categories
    packages[fullname] = package.categories
  end

  return packages
end

---
--- get all installed LSP servers
--- インストール済みのLSPサーバーを取得
---
--- @return lspclient[] lspclient object definition list
---
return function()
  local success, malspconfig = pcall(require, 'mason-lspconfig')
  if not success then
    return {}
  end
  local success, lspconfig = pcall(require, 'lspconfig')
  if not success then
    return {}
  end

  local packages = get_mason_category_map()

  local installed_servers = malspconfig.get_installed_servers()
  local lsp_name_mapping = malspconfig.get_mappings().lspconfig_to_mason
  -- インストール済みLSPの一覧を取得する
  local servers = {}
  for _, name in ipairs(installed_servers) do
    --local attached_buffer = client.attached_buffers[bn]
    local fullname = lsp_name_mapping[name]
    local client = util.get_init_client(name)
    local default_config = lspconfig[name].config_def.default_config

    client.cmd = default_config.cmd
    client.root_dir = default_config.root_dir()
    client.categories = packages[fullname]
    installed_servers[name] = client
    --vim.print("name: " .. name)
    --vim.print(default_config)
  end

  return installed_servers
end
