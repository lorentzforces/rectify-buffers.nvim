vim.api.nvim_create_user_command(
	"RectifyBuffers",
	function()
		require("rectify-buffers").rectify()
	end,
	{ desc = "Delete unused buffers and reload loaded ones" }
)
