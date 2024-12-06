---@diagnostic disable: undefined-global
local M = {}

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

M.setup = function()
  vim.api.nvim_create_user_command('Lspctl', function()
    M.run();
  end, {})
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
  local Menu = require("nui.menu")
  local event = require("nui.utils.autocmd").event

  local popup_head = Popup({
    border = {
      style = "double",
    },
  })

  local lines = {}
  for i, v in pairs(clients) do
    table.insert(lines, Menu.item(v.name, { id = v.id, attached = v.attached }))
  end

  if #lines < 1 then
    table.insert(lines, Menu.item("No Lsp"))
  end

  local menu = Menu({
    position = "50%",
    size = {
      width = 25,
      height = 5,
    },
    border = {
      style = "single",
      text = {
        top = "[Lsp Info and Wrapper]",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  }, {
    lines = lines,
    on_close = function()
      print("Menu Closed!")
    end,
    on_submit = function(item)
      print("Menu Submitted: ", item.text)
    end,
  })
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
    }, { dir = "col" })
  )

  popup_body:map("n", "q", function()
    layout:close()
    layout:unmount()
  end, {})
  layout:mount()

  local bufnr = vim.api.nvim_get_current_buf()
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
    table.insert(all_clients, c)
  end

  return all_clients
end

return M
