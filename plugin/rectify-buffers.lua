vim.api.nvim_create_user_command(
	"RectifyBuffers",
	function()
		require("rectify-buffers").rectify()
	end,
	{ desc = "Delete unused buffers and reload loaded ones" }
)

-- REMOVEME: debugging
vim.api.nvim_create_user_command(
	"ClassifyBuffers",
	function()
		require("rectify-buffers").classify_buffers()
	end,
	{ desc = "Check what rectify-buffers would do with buffers" }
)
