local M = {}

---@param opts table options
M.setup = function(opts)
    local plugin_path = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h")
    local binary_path = plugin_path .. '/rpc/bin/neovim-go-rpc'
    local rpc_dir = plugin_path .. '/rpc'

    -- stores the rpc job id for caching
    local chan

    local function build_binary()
        local build_cmd = { 'go', 'build', '-o', binary_path, '.' }
        local build_job = vim.fn.jobstart(build_cmd, {
            cwd = rpc_dir,
            on_exit = function(_, exit_code)
                if exit_code ~= 0 then
                    vim.notify('Failed to build RPC binary', vim.log.levels.ERROR)
                end
            end
        })
        vim.fn.jobwait({ build_job })
    end

    local function ensure_binary()
        if vim.fn.filereadable(binary_path) == 0 then
            build_binary()
        end
    end

    local function ensure_job()
      if chan then
        return chan
      end
      ensure_binary()
      chan = vim.fn.jobstart({ binary_path }, { rpc = true })
      return chan
    end

    vim.api.nvim_create_user_command('Hello', function(args)
      vim.fn.rpcrequest(ensure_job(), 'hello', args.fargs)
    end, { nargs = '*' })
end

return M
