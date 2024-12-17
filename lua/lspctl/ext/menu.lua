---@diagnostic disable: undefined-global
local Menu = require("nui.menu")

local EM = Menu:extend("ExtMenu")

function EM:init(o, options)
  EM.super.init(self, o, options)
  EM._keymap_tracker = {}
  EM._keymap_handler = {}
end

function EM:map(mode, key, handler, opts)
  opts = opts or {}
  opts.key = key

  if not EM._keymap_tracker[mode] then
    EM._keymap_tracker[mode] = {}
    EM._keymap_handler[mode] = {}
  end
  EM._keymap_tracker[mode][key] = true
  EM._keymap_handler[mode][key] = {
    modes = mode,
    keys = key,
    handlers = handler,
    opts = opts,
    fn = function()
      local o = EM._keymap_handler[mode][key]["opts"]
      local h = EM._keymap_handler[mode][key]["handlers"]
      h(o)
    end,
  }

  vim.keymap.set(mode, key, EM._keymap_handler[mode][key].fn, { noremap = true, silent = true, buffer = true })

  EM.super.map(self, mode, key, handler, {})
end

function EM:item(mode, key, handler, opts)
  return EM.super.item(self, mode, key, handler, opts)
end

function EM:unmap(mode, key)
  -- remove keymap from self._keymap_tracker
  EM.super.unmap(self, mode, key)
end

function EM:unmount()
  -- unmap keymaps from self._keymap_tracker
  EM.super.unmount(self)
end

return EM
