local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality

-- Create (but not start) child Neovim object
local child = MiniTest.new_child_neovim()

local T = new_set({
	hooks = {
		pre_case = function()
			child.restart({ '-u', 'scripts/minimal_init.lua' })
			child.lua([[M = require('rectify-buffers')]])
			child.lua([[M.setup({})]])
		end,
		post_once = child.stop,
	},
})

T['plugin'] = new_set()

T['plugin']['current file buffer is reloaded'] = function()
	child.cmd('edit tests/test_file.txt')

	local bufs = classify_buffers()

	local buf_info = expect_buffer_match_name(bufs, 'tests/test_file.txt')
	eq('reload', buf_info.action)
end

T['plugin']['file buffer with no file is untouched'] = function()
	child.cmd('edit tests/test_file.txt')
	child.cmd('edit fake_file.txt')

	local bufs = classify_buffers()

	local buf_info = expect_buffer_match_name(bufs, 'fake_file.txt')
	eq('none', buf_info.action)
end

T['plugin']['buffer with no window is marked for closing'] = function()
	child.cmd('edit tests/test_file.txt')
	child.cmd('edit fake_file.txt')

	local bufs = classify_buffers()

	local buf_info = expect_buffer_match_name(bufs, 'tests/test_file.txt')
	eq('close', buf_info.action)
end

T['plugin']['file buffer with changes is still reloaded'] = function()
	child.cmd('edit tests/test_file.txt')
	child.cmd('%s/lark/jabberwock')

	local bufs = classify_buffers()

	local buf_info = expect_buffer_match_name(bufs, 'tests/test_file.txt')
	eq('reload', buf_info.action)
end

T['plugin']['buffer types which should never be operated on are untouched'] = function()
	child.cmd('help testing.txt')

	local bufs = classify_buffers()

	local buf_info = expect_buffer_type(bufs, 'help')
	eq('none', buf_info.action)

	child.cmd('terminal')
	bufs = classify_buffers()
	buf_info = expect_buffer_type(bufs, 'terminal')
	eq('none', buf_info.action)
end

T['plugin']['a user function of an invalid type throws an error when calling setup'] = function()
	local success = pcall(function()
		child.lua_get([[M.setup({user_function = 2})]])
	end)

	if success then
		error(
			'expected an error when running setup() with a user_function value set to an '
				.. 'integer, but it succeeded'
		)
	end
end

T['plugin']['a vim cmd user function runs when RectifyBuffers is called'] = function()
	child.lua_get([[M.setup({ user_function = 'let g:test_var = "foo"'} )]])
	child.cmd('RectifyBuffers')
	local test_var_value = child.lua_get([[vim.g.test_var]])

	eq('foo', test_var_value)
end

T['plugin']['a lua user function runs when RectifyBuffers is called'] = function()
	child.lua_get([[M.setup({user_function = function() vim.g.test_var = 'foo' end})]])
	child.cmd('RectifyBuffers')
	local test_var_value = child.lua_get([[vim.g.test_var]])

	eq('foo', test_var_value)
end

function classify_buffers()
	return child.lua_get([[M.classify_buffers(false)]])
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
