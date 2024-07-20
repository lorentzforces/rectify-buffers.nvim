-- Define helper aliases
local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality

-- Create (but not start) child Neovim object
local child = MiniTest.new_child_neovim()

-- Define main test set of this file
local T = new_set({
	-- Register hooks
	hooks = {
		-- This will be executed before every (even nested) case
		pre_case = function()
		-- Restart child process with custom 'init.lua' script
		child.restart({ '-u', 'scripts/minimal_init.lua' })
		-- Load tested plugin
		child.lua([[M = require('rectify-buffers')]])
		end,
		-- This will be executed one after all tests from this set are finished
		post_once = child.stop,
	},
})

-- Test set fields define nested structure
T['basic'] = new_set()

T['basic']['gets a value'] = function()
  eq(child.lua_get([[M.hello()]]), 'Hello world')
end

return T
