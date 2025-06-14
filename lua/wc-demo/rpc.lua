local M = {}

---@param opts table options
M.setup = function(opts)
	-- dynamically get the plugin path
	local plugin_path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h")

	local rpc_dir = plugin_path .. "/rpc"
	local binary_path = rpc_dir .. "/bin/server"

    -- [[
    --     Helper Functions
    -- ]]

    -- build the rpc binary if it doesn't exist
	local function ensure_binary()
		local build_cmd = { "go", "build", "-o", binary_path, "." }
		if vim.fn.filereadable(binary_path) == 0 then
            local build_job = vim.fn.jobstart(build_cmd, {
                cwd = rpc_dir,
                on_exit = function(_, exit_code)
                    if exit_code ~= 0 then
                        vim.notify("Failed to build RPC binary", vim.log.levels.ERROR)
                    end
                end,
            })
		vim.fn.jobwait({ build_job })
		end
	end

	-- stores the rpc job id for caching
	local chan

    -- check if the rpc binary exists & if there is an existing job 
    -- if not create a new one
	local function ensure_job()
		if chan then
			return chan
		end
		ensure_binary()
		chan = vim.fn.jobstart({ binary_path }, { rpc = true })
		return chan
	end

    -- [[
    --     Register Commands
    -- ]]

    -- 1: Hello: just greet the caller
	vim.api.nvim_create_user_command("Hello", function(args)
		vim.fn.rpcrequest(ensure_job(), "hello", args.fargs)
	end, { nargs = "*" })

    -- 2: Wc: word count
	vim.api.nvim_create_user_command("Wc", function()
		local text_to_analyze = ""

		-- get visual selection
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")
		local lines = vim.fn.getline(start_pos[2], end_pos[2])

		if #lines == 1 then
			-- single line selection
			text_to_analyze = string.sub(lines[1], start_pos[3], end_pos[3])
		else
			-- multi-line selection
			lines[1] = string.sub(lines[1], start_pos[3])
			lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
			text_to_analyze = table.concat(lines, "\n")
		end

		vim.fn.rpcrequest(ensure_job(), "wc", { text_to_analyze })
	end, { nargs = "*", range = true })
end

return M
