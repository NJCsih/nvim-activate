local mod = require("nvim-activate")

vim.api.nvim_create_user_command("NvimActivateShow", function()
	mod.show()
end, { desc = "Show Activate Neonvim message" })

vim.api.nvim_create_user_command("NvimActivateHide", function()
	mod.hide()
end, { desc = "Hide Activate Neonvim message" })

vim.api.nvim_create_user_command("NvimActivateToggle", function()
	mod.toggle()
end, { desc = "Toggle Activate Neonvim message" })

vim.keymap.set("n", "<Plug>(NvimActivateShow)", function()
	mod.show()
end, { noremap = true, silent = true })
vim.keymap.set("n", "<Plug>(NvimActivateHide)", function()
	mod.hide()
end, { noremap = true, silent = true })
vim.keymap.set("n", "<Plug>(NvimActivateToggle)", function()
	mod.toggle()
end, { noremap = true, silent = true })

mod.setup()
