local M = {}

M.setup = function()
  vim.api.nvim_create_user_command('Lspctl', function()
    M.run();
  end, {})
end

M.run = function()
  local NuiTable = require("nui.table")

  local clients = vim.lsp.get_clients()

  local tbl = NuiTable({
    bufnr = bufnr,
    columns = {
      {
        align = "center",
        header = "Name",
        columns = {
          { accessor_key = "firstName", header = "First" },
          {
            id = "lastName",
            accessor_fn = function(row)
              return row.lastName
            end,
            header = "Last",
          },
        },
      },
      {
        align = "right",
        accessor_key = "age",
        cell = function(cell)
          return Text(tostring(cell.get_value()), "DiagnosticInfo")
        end,
        header = "Age",
      },
    },
    data = {
      { firstName = "John", lastName = "Doe", age = 42 },
      { firstName = "Jane", lastName = "Doe", age = 27 },
    },
  })

  tbl:render()
end

return M
