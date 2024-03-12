-- maybe refer to https://github.com/loctvl842/nvim/blob/33bc9bae4a0351bf6b36e7b4e71d476e75bef2cb/lua/beastvim/plugins/ui.lua#L161

return {
	{
		"dashboard-nvim",
		event = "VimEnter",
		opts = {
			config = {
				header = (function()
					local trim = function(s)
						return s:match("^%s*(.-)%s*$")
					end
					local logo = trim([[
┃      ⹁⹁    ⹁⹁           ┃
┃      |'\__/'|     (`\   ┃
┃    = | 'ㅅ' | =    ) )  ┃
┃--- ◜◜◜----- ◜◜◜---------┃
					]])
					logo = string.rep("\n", 2) .. logo .. string.rep("\n", 1)
					return vim.split(logo, "\n")
				end)(),
			},
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			hidden = {},
			layout = {
				height = { min = 4, max = 25 }, -- min and max height of the columns
				width = { min = 20, max = 50 }, -- min and max width of the columns
				spacing = 3, -- spacing between columns
				align = "left", -- align columns left, center or right
			},
			window = {
				border = "none", -- none|single|double
				position = "bottom",
				margin = { 1, 10, 5, 10 }, -- extra window margin [top, right, bottom, left]. When between 0 and 1, will be treated as a percentage of the screen size.
				padding = { 1, 2, 1, 2 }, -- extra window padding [top, right, bottom, left]
				winblend = 20, -- value between 0-100 0 for fully opaque and 100 for fully transparent
				zindex = 1000, -- positive value to position WhichKey above other floating windows.
			},
		},
	},
	{
		-- https://github.com/folke/noice.nvim/wiki/A-Guide-to-Messages#messages-and-notifications-in-neovim
		-- https://github.com/folke/noice.nvim/wiki/Configuration-Recipes
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			routes = {
				-- show @recording messages
				{
					view = "notify",
					filter = { event = "msg_showmode" },
				},
				-- hide presence.nvim stuff
				{
					filter = {
						kind = "echomsg",
						find = "presence",
					},
					opts = { skip = true },
				},
				-- hide the search?
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
						},
					},
					view = "mini",
				},
			},
		},
	},
}
