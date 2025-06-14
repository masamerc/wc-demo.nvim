local M = {}

local rpc = require('neovim-go-rpc.rpc')

-- define default options
local default_opts = {}

M.setup = function(opts)
    opts = vim.tbl_deep_extend("force", default_opts, opts or {})
    rpc.setup(opts)
end

return M
