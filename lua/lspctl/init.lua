---@diagnostic disable: undefined-global
local NuiText = require("nui.text")
local NuiLine = require("nui.line")
local NuiPopup = require("nui.popup")
local NuiLayout = require("nui.layout")
local NuiMenu = require("nui.menu")

local EM = require("lspctl.ext.menu")

local default_keymap = require("lspctl.config.keymap")
local actions = require("lspctl.actions")
local lspctlcore = require("lspctl.lsp")

local plugin_name = "lspctl"
local default_lsp_manager = "lspconfig"

---@class lspctl_config
---@field keymap lspctl_keymap
---@field manager "lspconfig"|"mason"

---table
---@class lspctl
---@field keymap lspctl_keymap
local M = {
  keymap = default_keymap,
  manager = default_lsp_manager,
  actions = actions,
}

---components
---@class lspctl_components
---@field header_popup table|nil
---@field menu table|nil
---@field layout table|nil
local components = {
  header_popup = nil,
  menu = nil,
  layout = nil,
}

local plugin_opts = {
  menu = {
    position = "50%",
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
  }
}

---
---setup - setup with initialize
---
---@param opt lspctl_config|nil config
---
M.setup = function(opt)
  vim.api.nvim_create_user_command('Lspctl', function()
    M.run();
  end, {})

  -- set config
  M.keymap = opt and opt.keymap or default_keymap
  M.manager = opt and opt.manager or default_lsp_manager
end

M.run = function()
  local clients = lspctlcore.get_all_clients({ manager = M.manager })
  M.render(clients)
end

---
---nui.menu用のitemリストを取得
---
---@param clients lspclient[]
---
components.get_menu_item_list = function(clients)
  local lines = {}
  for _, v in pairs(clients) do
    local idstr = v.id and "[id: " .. v.id .. "] " or "[id: -] "
    local id = NuiText(idstr, "Normal")

    local name = NuiText(v.name or "", "Title")

    local fullnamestr = v.fullname and " (" .. v.fullname .. ") " or ""
    local fullname = NuiText(fullnamestr, "Title")

    local attached = NuiText(v.attached and " (attached)" or " (detached)", "Comment")

    local categories = NuiText("", "Comment")
    if v.categories and #v.categories > 0 then
      categories = NuiText(" { " .. table.concat(v.categories, ", ") .. " }", "Comment")
    end

    local line = NuiLine({ id, name, fullname, attached, categories })
    local m = EM.item(line, { attached = v.attached })
    table.insert(lines, m)
  end

  return lines
end

---
---get_component_menu - nuiレイアウトのコンポーネントとしてのmenuを取得
---
---@param lines table
---
components.get_menu = function(lines)
  -- なかったら `ないです表示`
  if #lines < 1 then
    table.insert(lines, EM.item("No Lsp"))
  end

  -- menu
  if not components.menu then
    components.menu = EM(plugin_opts.menu, {
      lines = lines,
      keymap = {
        close = { "<Esc>", M.keymap.close },
      },
      on_close = function()
        components.layout:hide()
      end,
    })
  end

  -- box for menu-wrapped
  local menu_box = NuiLayout.Box(components.menu, {
    size = {
      width = "100%",
      height = "90%",
    },
    dir = "col"
  })

  return menu_box
end

components.get_header = function()
  if not components.header_popup then
    components.header_popup = NuiPopup({
      enter = true,
      focusable = false,
      border = {
        style = "rounded",
      },
    })
  end

  local header_box = NuiLayout.Box(components.header_popup, {
    size = "10%",
  })

  return header_box
end

M.get_action_help_text = function()
  return "[lspctl] start: " .. M.keymap.start ..
      " / stop: " .. M.keymap.stop ..
      " / restart: " .. M.keymap.restart ..
      " / quit: <ESC> or " .. M.keymap.close
end

M.reconfigure = function()
  if components.header_popup then
    vim.api.nvim_buf_set_lines(components.header_popup.bufnr, 0, 1, false, { M.get_action_help_text() })
  end

  local gb = vim.api.nvim_get_current_buf()

  local opt = { buffer = gb }
  components.menu:map("n", M.keymap.start, M.actions.start, opt)
  components.menu:map("n", M.keymap.stop, M.actions.stop, opt)
  components.menu:map("n", M.keymap.restart, M.actions.restart, opt)
end

---
---render - 描画
---
---@param clients lspclient[]
---
M.render = function(clients)
  M.actions.bufnr = vim.api.nvim_get_current_buf()
  M.actions.clients = clients
  --vim.print(clients)
  if components.layout then
    components.layout:show()
    M.reconfigure()
    return
  end

  local lines = components.get_menu_item_list(clients)
  local menu_box = components.get_menu(lines)
  local header_box = components.get_header()

  local layout_box = NuiLayout.Box({
    header_box,
    menu_box
  }, {
    dir = "col",
  })

  components.layout = NuiLayout(
    {
      position = "50%",
      size = {
        width = "80%",
        height = "50%",
      },
    },
    layout_box
  )

  components.layout:mount()
  vim.api.nvim_set_option_value("filetype", plugin_name, { buf = gb })
  M.reconfigure()
end

return M
