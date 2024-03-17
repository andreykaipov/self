return {
	{
		"nvim-telescope/telescope.nvim",
		event = "VeryLazy",
		dependencies = {
			{ "nvim-telescope/telescope-ui-select.nvim", event = "VeryLazy" },
			{ "nvim-telescope/telescope-file-browser.nvim", event = "VeryLazy" },
			-- lazy = true,
			-- https://github.com/nvim-telescope/telescope-fzf-native.nvim/issues/119#issuecomment-1873653249
			-- build = 'CFLAGS=-march=native make',
		},
		opts = function()
			local actions = require("telescope.actions")
			local actions_layout = require("telescope.actions.layout")
			return {
				defaults = {
					sort_mru = true,
					sorting_strategy = "ascending",
					layout_strategy = "vertical",
					layout_config = {
						center = {
							prompt_position = "top",
							width = 0.75,
							height = 0.75,
						},
						horizontal = {
							prompt_position = "top",
							width = 0.75,
							height = 0.75,
							preview_width = 0.65,
							preview_cutoff = 80,
						},
						vertical = {
							prompt_position = "top",
							width = 0.75,
							height = 0.9,
						},
					},
					border = true,
					multi_icon = "",
					entry_prefix = "   ",
					prompt_prefix = "   ",
					selection_caret = "  ",
					hl_result_eol = true,
					results_title = "",
					winblend = 0,
					wrap_results = true,
					mappings = {
						-- emacs-esque navigation in telescope
						i = {
							-- ["<esc>"] = actions.close,
							["<C-j>"] = actions.move_selection_next,
							["<C-k>"] = actions.move_selection_previous,
							["<C-u>"] = false,
							["<C-f>"] = actions.preview_scrolling_up,
							["<C-b>"] = actions.preview_scrolling_down,
							["<C-p>"] = actions_layout.toggle_preview,
							-- ["<A-t>"] = open_selected_with_trouble,
							-- ["<A-i>"] = find_files_no_ignore,
							-- ["<A-h>"] = find_files_with_hidden,
							-- ["<C-Down>"] = actions.cycle_history_next,
							-- ["<C-Up>"] = actions.cycle_history_prev,
							-- ["<C-t>"] = open_with_trouble,
						},
						n = {
							["q"] = actions.close,
							["j"] = actions.move_selection_next,
							["k"] = actions.move_selection_previous,
						},
					},
				},
				pickers = {
					find_files = {},
				},
				extensions = {
					file_browser = {
						theme = "ivy",
						initial_mode = "normal",
						hijack_netrw = true,
					},
				},
			}
		end,
		config = function(_, opts)
			require("telescope").setup(opts)
			require("telescope").load_extension("file_browser")
			require("telescope").load_extension("notify")
			require("telescope").load_extension("ui-select")
			vim.api.nvim_set_keymap(
				"n",
				"<leader>fb",
				":Telescope file_browser path=%:p:h select_buffer=true<CR>",
				{ noremap = true }
			)
			vim.api.nvim_set_keymap(
				"n",
				"<localleader>n",
				":Telescope notify theme=ivy initial_mode=normal<CR>",
				{ desc = "Open notifications", noremap = true }
			)
		end,
	},
}
