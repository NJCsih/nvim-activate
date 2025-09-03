---@class NvimActivateModule
---@field setup fun()
---@field show fun()
---@field hide fun()
---@field toggle fun()
---@field refresh fun()
---@diagnostic disable-next-line: missing-fields
---@type NvimActivateModule
local NvimActivate = {}

local H = {}

---@return nil
NvimActivate.setup = function()
	if H._did_setup == true then
		return
	end
	H.create_autocommands()
	vim.defer_fn(function()
		H.update_visibility()
	end, 0)
	H._did_setup = true
end

---@return nil
NvimActivate.show = function()
	if H.is_disabled() or H.get_window_id() then
		return
	end
	H.create_floating_window()
end

---@return nil
NvimActivate.hide = function()
	local win_id = H.get_window_id()
	if win_id and vim.api.nvim_win_is_valid(win_id) then
		vim.api.nvim_win_close(win_id, true)
	end
	H.clear_window_id()
end

---@return nil
NvimActivate.toggle = function()
	if H.get_window_id() then
		NvimActivate.hide()
	else
		NvimActivate.show()
	end
end

---@return nil
NvimActivate.refresh = function()
	if not H.get_window_id() then
		return
	end
	NvimActivate.hide()
	NvimActivate.show()
end

---@type integer|nil
H.win_id = nil

---@type integer
H.ns = vim.api.nvim_create_namespace("nvim-activate")

---@return nil
H.sync_highlight = function()
	local comment_hl = vim.api.nvim_get_hl(0, { name = "Comment" })
	local comment_fg = comment_hl and comment_hl.fg or nil
	vim.api.nvim_set_hl(0, "NvimActivateTitle", { fg = comment_fg, bg = "NONE", bold = true })
	vim.api.nvim_set_hl(0, "NvimActivate", { fg = comment_fg, bg = "NONE" })
end

---@return nil
H.create_autocommands = function()
	local gr = vim.api.nvim_create_augroup("NvimActivate", { clear = true })

	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "InsertLeave" }, {
		group = gr,
		pattern = "*",
		callback = function()
			vim.schedule(H.update_visibility)
		end,
		desc = "Update visibility on enter events",
	})

	vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave", "InsertEnter" }, {
		group = gr,
		pattern = "*",
		callback = function()
			vim.schedule(H.update_visibility)
		end,
		desc = "Update visibility on leave events",
	})

	vim.api.nvim_create_autocmd("OptionSet", {
		group = gr,
		pattern = "buftype",
		callback = function()
			vim.schedule(H.update_visibility)
		end,
		desc = "Update visibility after buftype change",
	})

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = gr,
		pattern = "*",
		callback = function()
			vim.schedule(H.sync_highlight)
		end,
		desc = "Sync highlight with colorscheme",
	})

	vim.api.nvim_create_autocmd("VimResized", {
		group = gr,
		pattern = "*",
		callback = NvimActivate.refresh,
		desc = "Recompute on editor resize if the window exists",
	})
end

---@return nil
H.update_visibility = function()
	if not H.is_disabled() then
		NvimActivate.show()
	else
		NvimActivate.hide()
	end
end

---@return integer
H.create_floating_window = function()
	local buf_id = vim.api.nvim_create_buf(false, true)

	local lines = {
		"Activate Neovim",
		"Go to Settings to activate Neovim.",
	}

	local width = 0
	for _, s in ipairs(lines) do
		width = math.max(width, vim.fn.strdisplaywidth(s or ""))
	end
	local height = #lines
	vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)

	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf_id })

	local grid_h = vim.o.lines - vim.o.cmdheight
	local row = math.max(0, grid_h - 2)
	local col = math.max(0, vim.o.columns - 2)

	local win_id = vim.api.nvim_open_win(buf_id, false, {
		relative = "editor",
		anchor = "SE",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "none",
		style = "minimal",
		focusable = false,
	})

	vim.api.nvim_set_option_value("winhighlight", "NormalFloat:Normal,Normal:Normal", { win = win_id })

	H.sync_highlight()
	vim.api.nvim_buf_set_extmark(buf_id, H.ns, 0, 0, {
		end_row = 0,
		end_col = #lines[1],
		hl_group = "NvimActivateTitle",
	})
	vim.api.nvim_buf_set_extmark(buf_id, H.ns, 1, 0, {
		end_row = 1,
		end_col = #lines[2],
		hl_group = "NvimActivate",
	})

	H.set_window_id(win_id)

	return win_id
end

---@return integer|nil
H.get_window_id = function()
	if H.win_id and vim.api.nvim_win_is_valid(H.win_id) then
		return H.win_id
	else
		return nil
	end
end

---@param win_id integer
H.set_window_id = function(win_id)
	H.win_id = win_id
end

---@return nil
H.clear_window_id = function()
	H.win_id = nil
end

---@return boolean
H.is_disabled = function()
	if vim.b.nvimactivate_disable ~= nil then
		return vim.b.nvimactivate_disable == true
	else
		return vim.g.nvimactivate_disable == true
	end
end

return NvimActivate
