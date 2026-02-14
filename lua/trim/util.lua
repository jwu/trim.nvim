local M = {}

---Check if a table contains a value
---@param tbl table
---@param val any
---@return boolean
function M.has_value(tbl, val)
  for _, v in ipairs(tbl) do
    if v == val then
      return true
    end
  end
  return false
end

return M
