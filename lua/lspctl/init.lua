---@diagnostic disable: undefined-global
local default_config = require("lspctl.keymap")
local actions = require("lspctl.actions")

local plugin_name = "lspctl"

---table
---@class lspctl
---@field config lspctl_config
local M = {
  config = default_config,
  actions = actions,
}

---lspclient object definition
---@class lspclient
---@field id integer
---@field name string
---@field version string
---@field offset_encoding string
---@field filetypes string
---@field initialization_options string
---@field attached string

---
---init - initialize
---
---@param opt lspctl_config|nil
---
--local function init(opt)
--  opt = (opt ~= nil and opt ~= {}) and opt or default_config
--  --local augroup = vim.api.nvim_create_augroup("Lspctl", { clear = true })
--  --vim.api.nvim_create_autocmd("FileType", {
--  --  group = augroup,
--  --  pattern = { "lspctl", },
--  --  callback = function()
--  --    vim.keymap.set("n", opt.info, "</<C-x><C-o>", { noremap = true, silent = true, buffer = true })
--  --  end,
--  --})
--end

---
---setup - setup with initialize
---
---@param opt lspctl_config|nil
---
M.setup = function(opt)
  vim.api.nvim_create_user_command('Lspctl', function()
    M.run();
  end, {})
  --init(opt)
end

M.run = function()
  local clients = M.get_clients()
  M.render(clients)
end

---
---render - 描画
---
---@param clients lspclient[]
---
M.render = function(clients)
  local Popup = require("nui.popup")
  local Layout = require("nui.layout")
  local EM = require("lspctl.ext.menu")
  --local event = require("nui.utils.autocmd").event

  local popup_head = Popup({
    border = {
      style = "double",
    },
  })

  local lines = {}
  for _, v in pairs(clients) do
    local m = EM.item(v.name, { id = v.id, attached = v.attached })
    table.insert(lines, m)
  end

  if #lines < 1 then
    table.insert(lines, EM.item("No Lsp"))
  end

  local menu_options = {
    position = "50%",
    size = {
      width = 25,
      height = 5,
    },
    border = {
      style = "single",
      text = {
        top = "[LspController]",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
    keymap = {
    },
  }

  local menu = EM(menu_options, {
    lines = lines,
    on_close = function()
      print("Menu Closed!")
    end,
    on_submit = function(item)
      print("Menu Submitted: ", item.text)
    end,
  })

  --menu:map("n", { M.config.start }, actions.start, { c = clients })
  --menu:map("n", { M.config.stop }, actions.stop, { c = clients })
  --menu:map("n", { M.config.restart }, actions.restart, { c = clients })
  M.actions.clients = clients
  menu:map("n", M.config.start, M.actions.start, {})
  menu:map("n", M.config.stop, M.actions.stop, {})
  menu:map("n", M.config.restart, M.actions.restart, {})


  local popup_body = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
    },
    --position = "50%",
    --size = {
    --  width = "80%",
    --  height = "60%",
    --},
    --buf_options = {
    --  modifiable = false,
    --  readonly = true,
    --  --buftype = "lspctl",
    --  --filetype = "lspctl",
    --  --bt = "lspctl",
    --  --ft = "lspctl",
    --},
  })
  local layout = Layout(
    {
      position = "50%",
      size = {
        width = "60%",
        height = "40%",
      },
    },
    Layout.Box({
      Layout.Box(popup_head, { size = "10%" }),
      Layout.Box(menu, { size = "90%" }),
    }, {
      dir = "col",
    })
  )

  popup_body:map("n", "q", function()
    layout:close()
    layout:unmount()
  end, {})
  layout:mount()

  local gb = vim.api.nvim_get_current_buf()
  vim.api.nvim_set_option_value("filetype", plugin_name, { buf = gb })
end

---
--- get_clients - クライアント取得
---
--- @return lspclient[]
---
M.get_clients = function()
  local clients = vim.lsp.get_clients()
  local bn = vim.api.nvim_get_current_buf()

  local all_clients = {}
  for _, client in pairs(clients) do
    local attached_buffer = client.attached_buffers[bn]
    local is_attached = attached_buffer ~= nil and attached_buffer == true
    local c = {
      id = client.id,
      name = client.name,
      version = client.version,
      offset_encoding = client.offset_encoding,
      filetypes = client.filetypes,
      initialization_options = client.initialization_options,
      attached = is_attached,
    }
    --table.insert(all_clients, c)
    all_clients[client.name] = c
  end

  return all_clients
end

return M
