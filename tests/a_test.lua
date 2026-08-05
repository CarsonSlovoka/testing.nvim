-- nvim -u ../lua/testing.lua -l a.lua
-- echo $? # 查看回傳的error code: 0是沒有錯誤

local testing = require("testing")
local t = testing.new()
t:eq(true, true)
_ = t:finish() or vim.cmd.cquit(1)
