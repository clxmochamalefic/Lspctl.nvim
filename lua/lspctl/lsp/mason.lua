---@diagnostic disable: undefined-global
local util = require('lspctl.lsp.util')

local function get_mason_category_map()
  local success, registry = pcall(require, 'mason-registry')
  if not success then
    return {}
  end

  local installed_packages = registry.get_installed_packages()

  local packages = {}
  for _, package in ipairs(installed_packages) do
    packages[package.name] = package.categories
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
  local s1, malspconfig = pcall(require, 'mason-lspconfig')
  if not s1 then
    return {}
  end
  local s2, lspconfig = pcall(require, 'lspconfig')
  if not s2 then
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
    local default_config = lspconfig[name].config_def.default_config
    local client = util.get_init_client(
      name,
      fullname,
      default_config.cmd,
      default_config.root_dir(),
      packages[fullname]
    )
    servers[name] = client
    --vim.print("name: " .. name)
    --vim.print(default_config)
  end

  return servers
end
