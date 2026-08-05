local t = require("testing")

t.test_error("有一個錯誤的測試", function()
  local b = false
  assert(b, "b is not true")
end)

t.test_error("錯誤要與期望相符", function()
  local b = false
  assert(b, "b is not true")
end, "b is not true")

t.test("全通過的測試", function()
  local a = true
  assert(a)
  local b = true
  assert(b, "b is not true")
end)

t.truthy("apple" ~= "banana", "my error message: apple ~= banana is true")
t.test_error("故意寫錯的測試: truthy", function()
  t.truthy("apple" == "banana", "apple == banana is false")
end)

t.eq("application/octet-stream", "application/octet-stream")
t.eq({ 1, 2, 3 }, { 1, 2, 3 }, "eq array 測試失敗")
t.eq(
  {
    1,
    info = {
      name = "foo",
      id = 123,
    },
    3
  },
  {
    1,
    info = { -- 欄位順序不同可以
      id = 123,
      name = "foo",
    },
    3
  },
  "eq table 測試失敗"
)
t.test_error("故意寫錯的測試: eq", function()
  local mime_type = "application/json"
  t.eq(mime_type, "application/octet-stream", "MIMEType not equal octet-stream")
end)
