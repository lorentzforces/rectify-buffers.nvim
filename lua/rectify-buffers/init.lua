local M = {}

function M.rectify()
	for _, buf in pairs(vim.api.nvim_list_bufs()) do
		local name = vim.api.nvim_buf_get_name(buf)
		local hasFile = buffer_has_file(buf)
		local listed = vim.api.nvim_buf_get_option(buf, 'buflisted')
		local hidden = vim.api.nvim_buf_get_option(buf, 'bufhidden')
		local windowCount = #vim.fn.win_findbuf(buf)
		-- see: https://neovim.io/doc/user/options.html#'modified'
		local modified = vim.api.nvim_get_option_value('modified', { buf = buf })
		-- see: https://neovim.io/doc/user/options.html#'buftype'
		local bufferType = vim.api.nvim_get_option_value('buftype', { buf = buf })

		-- TODO: make decisions based on this data

		log(string.format(
			"%s: %s, hasFile:%s, listed:%s, windowCount:%d, modified:%s, bufferType:%s",
			buf, name, hasFile, listed, windowCount, modified, bufferType
		))
	end
end

function buffer_has_file(buf_handle)
	local name = vim.api.nvim_buf_get_name(buf_handle)
	local file = io.open(name, "r")
	if (file) then
		file.close(file)
		return true
	end
	return false
end

function log(str)
	vim.cmd(string.format("echo \"%s\"", str))
end

return M
