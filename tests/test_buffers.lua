local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality

-- Create (but not start) child Neovim object
local child = MiniTest.new_child_neovim()

local T = new_set({
	hooks = {
		pre_case = function()
			child.restart({ '-u', 'scripts/minimal_init.lua' })
			child.lua([[M = require('rectify-buffers')]])
		end,
		post_once = child.stop,
	},
})

T['buffers'] = new_set()

T['buffers']['current file buffer is reloaded'] = function()
	child.cmd('edit tests/test_file.txt')

	local bufs = child.lua_get([[M.classify_buffers()]])

	local buf_info = expect_buffer_match_name(bufs, 'tests/test_file.txt')
	eq('reload', buf_info.action)
end

T['buffers']['file buffer with no file is untouched'] = function()
	child.cmd('edit tests/test_file.txt')
	child.cmd('edit fake_file.txt')

	local bufs = child.lua_get([[M.classify_buffers()]])

	local buf_info = expect_buffer_match_name(bufs, 'fake_file.txt')
	eq('none', buf_info.action)
end

T['buffers']['buffer with no window is marked for closing'] = function()
	child.cmd('edit tests/test_file.txt')
	child.cmd('edit fake_file.txt')

	local bufs = child.lua_get([[M.classify_buffers()]])

	local buf_info = expect_buffer_match_name(bufs, 'tests/test_file.txt')
	eq('close', buf_info.action)
end

T['buffers']['file buffer with changes is still reloaded'] = function()
	child.cmd('edit tests/test_file.txt')
	child.cmd('%s/lark/jabberwock')

	local bufs = child.lua_get([[M.classify_buffers()]])

	local buf_info = expect_buffer_match_name(bufs, 'tests/test_file.txt')
	eq('reload', buf_info.action)
end

T['buffers']['buffer types which should never be operated on are untouched'] = function()
	child.cmd('help testing.txt')

	local bufs = child.lua_get([[M.classify_buffers()]])

	local buf_info = expect_buffer_type(bufs, 'help')
	eq('none', buf_info.action)

	child.cmd('terminal')
	bufs = child.lua_get([[M.classify_buffers()]])
	buf_info = expect_buffer_type(bufs, 'terminal')
	eq('none', buf_info.action)
end

function expect_buffer_match_name(buffers, name)
	local name_length = #name -- this had better be a string
	for _, buffer_info in pairs(buffers) do
		local plain_search = true
		local matches = string.find(buffer_info.name, name, -name_length, plain_search)

		if matches ~= nil then
			return buffer_info
		end
	end
	error(string.format(
		'expected buffer_info matching buffer name "%s" in buffer list, but could not find one',
		name
	))
end

function expect_buffer_type(buffers, type)
	for _, buffer_info in pairs(buffers) do
		if buffer_info.type == type then
			return buffer_info
		end
	end
	error(string.format(
		'expected buffer_info matching buffer type "%s" in buffer list, but could not find one',
		type
	))
end

return T
