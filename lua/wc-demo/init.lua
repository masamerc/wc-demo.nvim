local M = {}

local rpc = require("wc-demo.rpc")

-- define default options for the plugin
local default_opts = {}

M.setup = function(opts)
    -- override default options if provided via setup call
	opts = vim.tbl_deep_extend("force", default_opts, opts or {})
	rpc.setup(opts)
end

return M
