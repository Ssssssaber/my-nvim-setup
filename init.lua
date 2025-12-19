-- TODO:
-- * breakpoints
-- * switcing between open editor
-- * git for seeing changes in a file
-- * global search, variable renaming

-- lazy nvim
local lazypath = vim.fn.stdpath("data") .. "lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath
	})
end

vim.opt.rtp:prepend(lazypath)

-- vim.lsp.config = 
require("lazy").setup({
	{
		'akinsho/bufferline.nvim',
		version = "*",
		dependencies = 'nvim-tree/nvim-web-devicons',
		config = function()
			require("bufferline").setup({
				options = {
					mode = "buffers", -- show open files
					separator_style = "slant", -- cosmetic style
					always_show_bufferline = true,
					show_buffer_close_icons = true,
					show_close_icon = true,
				}
			})

			-- Keybindings for switching buffers
			vim.keymap.set('n', '<C-Tab>', ':BufferLineCycleNext<CR>')
			vim.keymap.set('n', '<C-S-Tab>', ':BufferLineCyclePrev<CR>')
			
			-- Optional: Close current buffer (like closing a tab in VS Code)
			vim.keymap.set('n', '<leader>x', ':bdelete<CR>')
		end
	},
	{
		"preservim/nerdtree",
		dependencies = {
			"ryanoasis/vim-devicons",
		},
		config = function()
			vim.keymap.set('n', '<C-n>', ':NERDTreeToggle<CR>')
			vim.keymap.set('n', '<C-f>', ':NERDTreeFind<CR>')

			vim.keymap.set('n', '<C-h>', function()
				if vim.bo.filetype == 'nerdtree' then
					vim.cmd('wincmd p') -- Focus the previous window (the code)
				else
					vim.cmd('NERDTreeFocus') -- Focus NERDTree
				end
			end, { noremap = true, silent = true })

			vim.g.NERDTreeShowHidden = 1
			vim.g.NERDTreeMinimalUI = 1
			vim.g.NERDTreeArrowExpandable = '▸'
			vim.g.NERDTreeDirArrowCollapsible = '▾'
		end,
	},
	{
		"williamboman/mason.nvim",
		config = true,
    },
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				mapping = cmp.mapping.preset.insert({
					-- This maps Enter to confirm the suggestion
					['<CR>'] = cmp.mapping.confirm({ 
						select = true, -- Set to true to select the top suggestion automatically
						behavior = cmp.ConfirmBehavior.Replace 
					}),
					-- Use Tab to cycle through suggestions
					['<Tab>'] = cmp.mapping.select_next_item(),
					['<S-Tab>'] = cmp.mapping.select_prev_item(),
				}),
				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					{ name = 'buffer' },
					{ name = 'path' },
				})
			})
		end,
	},
	{
		"Saghen/blink.cmp",
		version = "*", -- Use latest release
		opts = {
			keymap = { preset = "default" }, -- Enter to confirm, Ctrl+n/p to select
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono"
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "clangd" }, -- Fixed typo: ensure_installed
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
		config = function()
			local capabilites = require('blink.cmp').get_lsp_capabilities()

			vim.lsp.enable("clangd")
			vim.lsp.config("*", {
				capabilites = capabilites
			})
		end,
	},

	-- 1. LLDB Support (nvim-dap)
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",      -- UI for the debugger
			"nvim-neotest/nvim-nio",     -- Required for dap-ui
			"jay-babu/mason-nvim-dap.nvim", -- Connects mason to dap
		},

		keys = {
			{ "<leader>b", function() require('dap').toggle_breakpoint() end, desc = "Toggle Breakpoint" },
			{ "<F5>", function() require('dap').continue() end, desc = "Debug Continue" },
			{ "<F10>", function() require('dap').step_over() end, desc = "Step Over" },
			{ "<F11>", function() require('dap').step_into() end, desc = "Step Into" },
		},

		config = function()
			local dap, dapui = require("dap"), require("dapui")
			require("mason-nvim-dap").setup({
				ensure_installed = { "codelldb" },
				handlers = {},
			})
			dapui.setup()

			-- Auto open/close UI
			dap.listeners.before.attach.dapui_config = function() dapui.open() end
			dap.listeners.before.launch.dapui_config = function() dapui.open() end
			dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
			dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

			-- 2. Define your icons here (or at the bottom of init.lua)
			vim.fn.sign_define('DapBreakpoint', { text='🛑', texthl='DapBreakpoint' })
			vim.fn.sign_define('DapStopped', { text='➡️', texthl='DapStopped' })
		end,
	},

	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"jay-babu/mason-null-ls.nvim",
		},
		config = function()
			local null_ls = require("null-ls")

			-- Automates installation of formatters/linters
			require("mason-null-ls").setup({
				ensure_installed = { "clang_format", "cppcheck", "stylua" },
				automatic_installation = true,
			})

			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.clang_format,
					null_ls.builtins.diagnostics.cppcheck,
					null_ls.builtins.formatting.stylua,
				},
			})
			vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, {})
		end,
	},
})

-- _Preferences
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.wrap = true
vim.opt.cursorline = true
vim.opt.scrolloff = 10

vim.opt.mouse = 'a'

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.undofile = true
vim.opt.backup = true

vim.opt.hlsearch = true
vim.opt.inccommand = 'split'
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- vim.cmd [[
-- 	iabbrev @@ keke
-- ]]
-- vim.keymap.set('i', 'jk', '<Esc>')
-- vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
-- 	pattern = '*.c',
-- 	callback = function()
-- 		vim.keymap.set('i', '(', '() {<Esc><Left><Left>i')
-- 	end,
-- })

-- _Keybindings

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set('n', '<leader>d', '"_d')
vim.keymap.set('v', '<leader>d', '"_d')

vim.opt.clipboard = 'unnamedplus'

vim.keymap.set('n', '<leader>a', ':belowright split | term<CR>')

vim.keymap.set('n', '<C-j>', ':m .+1<CR>>==')
vim.keymap.set('n', '<C-k>', ':m .-2<CR>>==')

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.keymap.set('v', "<leader>'", "c''<Esc>P")
vim.keymap.set('v', '<leader>"', 'c""<Esc>P')
vim.keymap.set('v', "<leader>(", "c()<Esc>P")
vim.keymap.set('v', "<leader>{", "c{}<Esc>P")
vim.keymap.set('v', "<leader>[", "c[]<Esc>P")

vim.keymap.set('n', '<leader>li', 'i[]()<Left><Left><Esc>a')

vim.keymap.set('n', '<Esc', '<cmd>nohlsearch<CR>')

