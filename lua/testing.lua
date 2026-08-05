local M = {}

---@alias TestingErrorMatcher string|fun(error_message: string): boolean

---@class TestingOptions
---@field writer? fun(line: string)
---@field fail_fast? boolean 遇到第一個失敗時立即停止. 並且也會有完成的call stack因為它會觸發error

---@class TestingResult
---@field name string
---@field ok boolean
---@field error? string

---@class TestingSummary
---@field total integer
---@field passed integer
---@field failed integer
---@field results TestingResult[]

---@class TestingRunner
---@field private _passed integer
---@field private _failed integer
---@field private _results TestingResult[]
---@field private _writer fun(line: string)
---@field private _fail_fast boolean
local Runner = {}

Runner.__index = Runner

---@param line string
local function default_writer(line)
  io.write(line, "\n")
end

---@param err unknown
---@return string
local function traceback_handler(err)
  return debug.traceback(tostring(err), 2)
end

---@param message string
---@return string
---@return integer count
local function indent(message)
  return message:gsub("\n", "\n   ")
end

---@param options? TestingOptions
---@return TestingRunner
function M.new(options)
  options = options or {}

  return setmetatable({
    _passed = 0, -- 計數，曉得一次測試中，總共成功的次數
    _failed = 0,
    _results = {},
    _writer = options.writer or default_writer,
    _fail_fast = options.fail_fast == true,
  }, Runner)
end

---@private
---@param name string
---@param ok boolean
---@param err? string
---@return boolean
function Runner:_record(name, ok, err)
  ---@type TestingResult
  local result = {
    name = name,
    ok = ok,
    error = err,
  }

  self._results[#self._results + 1] = result

  if ok then
    self._passed = self._passed + 1
    self._writer("✅ " .. name)
    return true
  end

  self._failed = self._failed + 1
  self._writer("❌ " .. name)

  if err then
    self._writer("   " .. indent(err))
  end

  if self._fail_fast then
    error(err or ("test failed: " .. name), 0)
  end

  return false
end

---期望 callback 正常執行
---@param name string
---@param callback fun()
---@return boolean
function Runner:test(name, callback)
  assert(type(name) == "string", "name must be a string")
  assert(type(callback) == "function", "callback must be a function")

  -- local ok, err = pcall(callback) -- 會希望可以看到錯誤的位置，而如果不觸發到error，位置就會不曉得，所以可以用xpcall, 來客製err的訊息. Note: 如果直接觸發error將會整個中斷
  local ok, err = xpcall(callback, traceback_handler) -- xpcall與pcall類似，但它可以制定error handler.

  return self:_record(name, ok, err)
end

---期望 callback 發生錯誤
---
---expected 是字串時，使用純文字比對，不會被當作 Lua pattern
---expected 是函式時，可自行判斷錯誤內容
---@param name string
---@param callback fun()
---@param expected? TestingErrorMatcher
---@return boolean
function Runner:test_error(name, callback, expected)
  assert(type(name) == "string", "name must be a string")
  assert(type(callback) == "function", "callback must be a function")

  local ok, err = xpcall(callback, traceback_handler)

  if ok then
    return self:_record(name, false, "expected an error, but no error occurred")
  end

  if expected == nil then
    return self:_record(name, true)
  end

  if type(expected) == "string" then
    if err:find(expected, 1, true) then
      return self:_record(name, true)
    end

    return self:_record(
      name,
      false,
      ("expected error containing:\n%s\nactual error:\n%s"):format(
        expected,
        err
      )
    )
  end

  if type(expected) == "function" then
    local matcher_ok, matched = pcall(expected, err)

    if not matcher_ok then
      return self:_record(
        name,
        false,
        "error matcher itself failed:\n" .. tostring(matched)
      )
    end

    if matched then
      return self:_record(name, true)
    end

    return self:_record(
      name,
      false,
      "error did not match expectation:\n" .. err
    )
  end

  error("expected must be a string, function, or nil", 2)
end

---@param actual unknown
---@param expected unknown
---@param message? string
function Runner:eq(actual, expected, message)
  if vim.deep_equal(actual, expected) then
    return
  end

  error(
    ("%s\nexpected: %s\nactual:   %s"):format(
      message or "values are not equal",
      vim.inspect(expected),
      vim.inspect(actual)
    ),
    2
  )
end

---@param value unknown
---@param message? string
---@param level? integer
function Runner:truthy(value, message, level)
  if value then
    return
  end

  error(message or "expected a truthy value", level or 2)
end

---@param value unknown
---@param message? string
---@param level? integer
function Runner:falsy(value, message, level)
  if not value then
    return
  end

  error(message or "expected a falsy value", level or 2)
end

---@return TestingSummary
function Runner:summary()
  return {
    total = self._passed + self._failed,
    passed = self._passed,
    failed = self._failed,
    results = vim.deepcopy(self._results),
  }
end

---@return boolean success
---@return TestingSummary summary
function Runner:finish()
  local summary = self:summary()

  self._writer("")
  self._writer(
    ("📊 Tests: %d total, %d passed, %d failed"):format(
      summary.total,
      summary.passed,
      summary.failed
    )
  )

  return summary.failed == 0, summary
end

return M
