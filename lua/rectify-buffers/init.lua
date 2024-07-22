local M = {}

local ACTION_CLOSE = 'close'
local ACTION_RELOAD = 'reload'
local ACTION_NONE = 'none'

local NOT_VERBOSE = false
function M.rectify()
	local buffers = M.classify_buffers(NOT_VERBOSE)
	for _, buffer_info in pairs(buffers) do
		if buffer_info.action == ACTION_CLOSE then
			vim.api.nvim_buf_delete(buffer_info.id, {})
		elseif buffer_info.action == ACTION_RELOAD then
			-- TODO: eventually provide some kind of user confirmation to reload buffers like this that DO
			-- have changes
			vim.api.nvim_buf_call(buffer_info.id, function() vim.cmd('edit!') end)
		end
	end
end

function M.classify_buffers(verbose_logging)
	local buffers = {}
	for _, buf in pairs(vim.api.nvim_list_bufs()) do
		local name = vim.api.nvim_buf_get_name(buf)
		local has_file = buffer_has_file(buf)
		local listed = vim.api.nvim_buf_get_option(buf, 'buflisted')
		local window_count = #vim.fn.win_findbuf(buf)
		-- see: https://neovim.io/doc/user/options.html#'buftype'
		local buffer_type = vim.api.nvim_get_option_value('buftype', { buf = buf })

		-- TODO: maybe take modified state into account?
		-- see: https://neovim.io/doc/user/options.html#'modified'
		-- local modified = vim.api.nvim_get_option_value('modified', { buf = buf })

		local action = ACTION_NONE

		if should_ignore_buffer_type(buffer_type) then
			goto continue
		end
		if not listed then
			goto continue
		end

		if window_count == 0 then
			action = ACTION_CLOSE
		elseif has_file then
			action = ACTION_RELOAD
		end

		::continue::

		if verbose_logging then
			log(string.format(
				'[%s] \'%s\' -- action:%s type:%s has_file:%s listed:%s window_count%s',
				buf, name, action, buffer_type, has_file, listed, window_count
			))
		end

		local buffer_info = {}
		buffer_info.id = buf
		buffer_info.name = name
		buffer_info.type = buffer_type
		buffer_info.action = action
		table.insert(buffers, buffer_info)
	end

	return buffers
end

function buffer_has_file(buf_handle)
	local name = vim.api.nvim_buf_get_name(buf_handle)
	local file = io.open(name, 'r')
	if file then
		file.close(file)
		return true
	end
	return false
end

function log(str)
	vim.cmd(string.format('echo "%s"', str))
end

function set(list)
	local set = {}
	for _, val in ipairs(list) do
		set[val] = true
	end
	return set
end

local bufferSkipType = set({
	'help',
	'prompt',
	'quickfix',
	'terminal',
})

function should_ignore_buffer_type(buf_type)
	if bufferSkipType[buf_type] then
		return true
	end
	return false
end

return M
