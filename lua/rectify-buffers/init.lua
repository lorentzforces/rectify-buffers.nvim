local M = {}

function set(list)
	local set = {}
	for _, val in ipairs(list) do
		set[val] = true
	end
	return set
end

local bufferSkipType = set({
	"help",
	"prompt",
	"quickfix",
	"terminal",
})

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

		local closeBuffer = true
		if bufferSkipType[bufferType] then
			closeBuffer = false
		end
		if not hasFile then
			closeBuffer = false
		end
		if not listed then
			closeBuffer = false
		end
		if windowCount > 0 then
			closeBuffer = false
		end

		-- TODO: ignoring modified status for now, and hopefully buffer delete just takes care of
		-- that for us
		-- SURVEY SAYS: KIND OF

		log(string.format(
			"[%s] %s -- closeBuffer:%s bufferType:%s hasFile:%s listed:%s windowCount:%s",
			buf, name, closeBuffer, bufferType, hasFile, listed, windowCount
		))

		if closeBuffer then
			vim.api.nvim_buf_delete(buf, {})
		end
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
