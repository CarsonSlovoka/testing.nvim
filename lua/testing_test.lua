local testing = require("testing")
local t = testing.new()
-- local t = testing.new({ fail_fast = true }) -- Tip: 如果故意改錯，想要看觸發的詳細位置，可以改用這樣

t:test("不同 runner 的狀態互相獨立", function()
  local silent = function() end

  local first = testing.new({
    writer = silent,
  })

  local second = testing.new({
    writer = silent,
  })

  first:test("first test", function()
    assert(true)
  end)

  local first_summary = first:summary()
  local second_summary = second:summary()

  t:eq(first_summary.passed, 1)
  t:eq(first_summary.failed, 0)

  t:eq(second_summary.passed, 0)
  t:eq(second_summary.failed, 0)
end)

t:test_error("有一個錯誤的測試", function()
  local b = false
  assert(b, "b is not true")
end)

t:test_error("錯誤要與期望相符",
  function()
    local b = false
    assert(b, "b is not true")
  end,
  "b is not true"
)

t:test_error("可以使用函式比對錯誤", function()
    error("HTTP status: 404")
  end,
  function(err)
    return err:find("HTTP status: 404", 1, true) ~= nil
  end
)

t:test("全通過的測試", function()
  local a = true
  assert(a)

  local b = true
  assert(b, "b is not true")
end)

t:test("truthy 測試", function()
  local val = true
  t:truthy(val, "err. value is not true")
end)

t:test("falsy測試", function()
  t:falsy(3 == 2)
end)


t:test_error("故意寫錯的測試：truthy", function()
  local val = false
  t:truthy(val, "err. value is not true")
end, "err. value is not true")

t:test("eq 字串測試", function()
  t:eq(
    "application/octet-stream",
    "application/octet-stream"
  )
end)

t:test("eq array 測試", function()
  t:eq(
    { 1, 2, 3 },
    { 1, 2, 3 },
    "eq array 測試失敗"
  )
end)

t:test("eq table 測試", function()
  t:eq(
    {
      1,
      info = {
        name = "foo",
        id = 123,
      },
      3,
    },
    {
      1,
      info = {
        id = 123, -- 順序變沒關係
        name = "foo",
      },
      3,
    },
    "eq table 測試失敗"
  )
end)

t:test_error("故意寫錯的測試：eq", function()
  local mime_type = "application/json"

  t:eq(
    mime_type,
    "application/octet-stream",
    "MIMEType not equal octet-stream"
  )
end, "MIMEType not equal octet-stream")

local success = t:finish()

if not success then
  vim.cmd.cquit(1) -- 可以觸發exit代碼，使得用github action cli有辦法得到錯誤
end
