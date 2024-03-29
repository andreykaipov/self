---@diagnostic disable: inject-field

local M = require("lazyvim.util")

-- e.g. Util.ui.fg("Statement") to fetch the color for a specific highlight group
-- see: https://github.com/oxfist/night-owl.nvim/blob/main/lua/night-owl/theme.lua

function M.ui.color(name)
	local hl = vim.api.nvim_get_hl(0, { name = name })
	local fg = hl and hl.fg or nil
	local bg = hl and hl.bg or nil
	local color = {
		fg = fg and string.format("#%06x", fg) or "none",
		bg = bg and string.format("#%06x", bg) or "none",
	}
	return hl and color or nil
end

function M.trim(s)
	return s:match("^%s*(.-)%s*$")
end

function M.augroup(name)
	return vim.api.nvim_create_augroup("mylazyvim-" .. name, { clear = true })
end

function M.dump(x)
	local function serialize(o)
		if type(o) == "table" then
			local s = "{ "
			for k, v in pairs(o) do
				if type(k) ~= "number" then
					k = '"' .. k .. '"'
				end
				s = s .. "[" .. k .. "] = " .. serialize(v) .. ", "
			end
			return s .. "} "
		else
			return tostring(o)
		end
	end
	print(serialize(x))
end

function M.lsp_servers(opts)
	opts = (opts == nil and {}) or opts

	local msg = "No Active LSP"
	local buf_clients = vim.lsp.get_active_clients()
	if next(buf_clients) == nil then
		return msg
	end

	local null_ls_installed, null_ls = pcall(require, "null-ls")
	local lsps_null = {}
	local lsps_other = {}
	for _, client in pairs(buf_clients) do
		if client.name == "null-ls" then
			if null_ls_installed then
				for _, source in ipairs(null_ls.get_source({ filetype = vim.bo.filetype })) do
					table.insert(lsps_null, source.name)
				end
			end
		else
			table.insert(lsps_other, client.name)
		end
	end

	table.sort(lsps_null)
	table.sort(lsps_other)

	if opts.lualine then
		local prefix = table.concat(lsps_other, ",")
		local suffix = table.concat(lsps_null, ",")
		if suffix == "" then
			suffix = "empty"
		end
		if prefix ~= "" then
			prefix = prefix .. "│"
		end
		if string.len(suffix) > 40 or vim.fn.winwidth(0) < 120 then
			suffix = "null_ls"
		end

		return prefix .. suffix
	end

	return {
		other_ls = lsps_other,
		null_ls = lsps_null,
	}
end

return M
