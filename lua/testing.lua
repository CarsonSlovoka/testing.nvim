local M = {}

--- 期望都正確的測試
---
---@param name     string
---@param callback fun()
function M.test(name, callback)
  local success, err = pcall(callback)
  if success then
    print("✅ " .. name)
    return
  end

  print("❌ " .. name)
  print("   " .. vim.inspect(err))
end

--- 期望有錯的測試
---
---@param name string
---@param callback fun()
---@param expected? string
function M.test_error(name, callback, expected)
  local ok, err = pcall(callback)

  if ok then
    print("❌ " .. name)
    print("   expected an error")
    return
  end

  err = tostring(err)

  if expected and not err:find(expected, 1, true) then
    print("❌ " .. name)
    print("   expected: " .. expected)
    print("   actual:   " .. err)
    return
  end

  print("✅ " .. name)
end

---@param actual unknown
---@param expected unknown
---@param message? string
function M.eq(actual, expected, message)
  if not vim.deep_equal(expected, actual) then
    error(("❌ %s\nexpected: %s\nactual:   %s"):format(
      message or "values are not equal",
      vim.inspect(expected),
      vim.inspect(actual)
    ), 2)
  end
end

---@param value unknown
---@param message string
---@param level integer? 影響message的定位的錯誤所在. 但因為最後用error，所以有錯還是可以從call statck中看出
function M.truthy(value, message, level)
  if not value then
    error("❌ " .. message, level or 2)
  end
end

return M
