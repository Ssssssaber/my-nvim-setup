vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Preferences
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.inccommand = "split"
vim.opt.list = true

-- Use standard ASCII for listchars
vim.opt.listchars = { tab = "> ", trail = ".", nbsp = "_" }

-- Keybindings
vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')
vim.opt.clipboard = "unnamedplus"
vim.keymap.set("n", "<leader>a", ":belowright split | term<CR>")
vim.keymap.set("n", "<C-j>", ":m .+1<CR>==")
vim.keymap.set("n", "<C-k>", ":m .-2<CR>==")
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})
vim.keymap.set("v", "<leader>'", 'c""<Esc>P')
vim.keymap.set("v", '<leader>"', 'c""<Esc>P')
vim.keymap.set("v", "<leader>(", "c()<Esc>P")
vim.keymap.set("v", "<leader>{", "c{}<Esc>P")
vim.keymap.set("v", "<leader>[", "c[]<Esc>P")
vim.keymap.set("n", "<leader>li", "i[]()<Left><Left><Esc>a")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<CR>", function()
	if vim.v.hlsearch == 1 then
		vim.cmd("nohlsearch")
	end
	return "<CR>"
end, { expr = true, silent = true })

