local testing = require("testing")
local t = testing.new()
t:eq(true, true)
_ = t:finish() or vim.cmd.cquit(1)
