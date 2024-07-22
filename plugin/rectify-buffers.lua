vim.api.nvim_create_user_command(
	"RectifyBuffers",
	function()
		require("rectify-buffers").rectify()
	end,
	{ desc = "Delete unused buffers and reload loaded ones" }
)

local VERBOSE = true
vim.api.nvim_create_user_command(
	"RectifyBuffersDebug",
	function()
		require("rectify-buffers").classify_buffers(VERBOSE)
	end,
	{ desc = "Check what rectify-buffers would do with buffers" }
)
