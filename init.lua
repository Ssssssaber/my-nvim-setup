
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- lazy nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
	  "S1M0N38/love2d.nvim",
	  event = "VeryLazy",
	  version = "2.*",
	  opts = { },
	  keys = {
		{ "<leader>v", ft = "lua", desc = "LÖVE" },
		{ "<leader>vv", "<cmd>LoveRun<cr>", ft = "lua", desc = "Run LÖVE" },
		{ "<leader>vs", "<cmd>LoveStop<cr>", ft = "lua", desc = "Stop LÖVE" },
	  },
	},
	{
		'skywind3000/asyncrun.vim',
		config = function()
		  vim.g.asyncrun_open = 8
		end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
		  require("tokyonight").setup({
			style = "storm",
			transparent = false,
			terminal_colors = true,
			styles = {
			  comments = { italic = true },
			  keywords = { italic = true },
			},
		  })
		  vim.cmd([[colorscheme tokyonight-storm]])
		end,
	},
	  -- Telescope
	  {
		'nvim-telescope/telescope.nvim', tag = '0.1.8',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
		  local builtin = require('telescope.builtin')
		  vim.keymap.set('n', '<C-f>', builtin.find_files, {})
		  vim.keymap.set('n', '<C-fv>', builtin.live_grep, {})
		  vim.keymap.set('n', '<leader>sg', builtin.live_grep, {})
		  vim.keymap.set('n', '<leader>er', '<cmd>Telescope diagnostics<CR>', { desc = 'Open Telescope diagnostics' })
		end
	},
  -- Git: Use text indicators
	  {
		"lewis6991/gitsigns.nvim",
		config = function()
		  require('gitsigns').setup({
			signs = {
			  add = { text = "+" },
			  change = { text = "~" },
			  delete = { text = "-" },
			  topdelete = { text = "-" },
			  changedelete = { text = "~" },
			},
		  })
		end
	  },
	  -- Bufferline: Use text labels
	  {
		'akinsho/bufferline.nvim',
		version = "*",
		config = function()
		  require("bufferline").setup({
			options = {
			  mode = "buffers",
			  separator_style = "slant",
			  always_show_bufferline = true,
			  show_buffer_close_icons = false,
			  show_close_icon = false,
			  indicator = { style = 'icon', icon = ' ' },
			  modified_icon = "+",
			  close_icon = "X",
			  left_trunc_marker = "<",
			  right_trunc_marker = ">",
			}
		  })
		  vim.keymap.set('n', '<C-Tab>', ':BufferLineCycleNext<CR>', { silent = true })
		  vim.keymap.set('n', '<C-S-Tab>', ':BufferLineCyclePrev<CR>', { silent = true })
		  vim.keymap.set('n', 'H', ':BufferLineCyclePrev<CR>')
		  vim.keymap.set('n', 'L', ':BufferLineCycleNext<CR>')
		  vim.keymap.set('n', '<leader>x', ':bdelete<CR>')
		end
	  },
	  -- NERDTree: Use text arrows
	  {
		"preservim/nerdtree",
		config = function()
		  vim.keymap.set('n', '<C-n>', ':NERDTreeToggle<CR>')
		  vim.keymap.set('n', '<C-h>', function()
			if vim.bo.filetype == 'nerdtree' then
			  vim.cmd('wincmd p')
			else
			  vim.cmd('NERDTreeFocus')
			end
		  end, { noremap = true, silent = true })
		  vim.g.NERDTreeShowHidden = 1
		  vim.g.NERDTreeMinimalUI = 1
		  vim.g.NERDTreeArrowExpandable = '>'
		  vim.g.NERDTreeDirArrowCollapsible = 'v'
		end,
	  },
	  { "williamboman/mason.nvim", config = true },
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
			  ['<CR>'] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
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
		version = "*",
		opts = {
		  keymap = { preset = "default" },
		  appearance = { use_nvim_cmp_as_default = true },
		  sources = { default = { "lsp", "path", "snippets", "buffer" } },
		},
	  },
	  {
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
		  require("mason-lspconfig").setup({ ensure_installed = { "clangd", "lua_ls" } })
		end,
	  },
	  {
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
		config = function()

		  local capabilities = require('blink.cmp').get_lsp_capabilities()
		  vim.lsp.enable("clangd")
		  vim.lsp.config("clangd", { capabilities = capabilities })

		  vim.lsp.enable("lua_ls")
		  vim.lsp.config("lua_ls", {
			  capabilities = capabilities,
			  settings = {
					Lua = {
					  runtime = {
						version = 'LuaJIT',
					  },
					  diagnostics = {
						globals = { 'vim' },
					  },
					  workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
					  },
					  telemetry = {
						enable = false,
					  },
				  }
			  }
		  })

		  vim.keymap.set('n', '<F12>', vim.lsp.buf.definition, {})
		  vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, { desc = "References" })
		  vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, {})
		  vim.keymap.set('n', 'gh', vim.lsp.buf.hover, { desc = "Show Hover Docs" })
		end,
	  },
	  {
		"mfussenegger/nvim-dap",
		dependencies = {
		  "rcarriga/nvim-dap-ui",
		  "nvim-neotest/nvim-nio",
		  "jay-babu/mason-nvim-dap.nvim",
		},
		keys = {
		  { "<leader>bp", function() require('dap').toggle_breakpoint() end, desc = "Toggle Breakpoint" },
		  { "<F5>", function() require('dap').continue() end, desc = "Debug Continue" },
		  { "<F10>", function() require('dap').step_over() end, desc = "Step Over" },
		  { "<F11>", function() require('dap').step_into() end, desc = "Step Into" },
		},
		config = function()
		  local dap, dapui = require("dap"), require("dapui")
		  require("mason-nvim-dap").setup({ ensure_installed = { "codelldb" }, handlers = {} })
		  dapui.setup()
		  local last_executable_path = nil
		  dap.configurations.cpp = {
			{
			  name = "Launch (Remembered Path)",
			  type = "codelldb",
			  request = "launch",
			  program = function()
				local default = last_executable_path or (vim.fn.getcwd() .. '/')
				local path = vim.fn.input('Path to executable: ', default, 'file')
				if path ~= "" then last_executable_path = path; return path end
			  end,
			  cwd = function()
				if last_executable_path then return vim.fn.fnamemodify(last_executable_path, ":h") end
				return "${workspaceFolder}"
			  end,
			  stopOnEntry = false,
			},
		  }
		  dap.configurations.c = dap.configurations.cpp
		  dap.listeners.before.attach.dapui_config = function() dapui.open() end
		  dap.listeners.before.launch.dapui_config = function() dapui.open() end
		  dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
		  dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
		  -- Use text for breakpoint signs
		  vim.fn.sign_define('DapBreakpoint', { text = 'B', texthl = 'DapBreakpoint' })
		  vim.fn.sign_define('DapStopped', { text = '->', texthl = 'DapStopped' })
		end,
	  },
	  {
		"nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "jay-babu/mason-null-ls.nvim" },
		config = function()
		  local null_ls = require("null-ls")
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

-- Preferences
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
-- Use standard ASCII for listchars
vim.opt.listchars = { tab = '> ', trail = '.', nbsp = '_' }

-- Keybindings
vim.keymap.set('n', '<leader>d', '"_d')
vim.keymap.set('v', '<leader>d', '"_d')
vim.opt.clipboard = 'unnamedplus'
vim.keymap.set('n', '<leader>a', ':belowright split | term<CR>')
vim.keymap.set('n', '<C-j>', ':m .+1<CR>==')
vim.keymap.set('n', '<C-k>', ':m .-2<CR>==')
vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank() end })
vim.keymap.set('v', "<leader>'", 'c""<Esc>P')
vim.keymap.set('v', '<leader>"', 'c""<Esc>P')
vim.keymap.set('v', "<leader>(", 'c()<Esc>P')
vim.keymap.set('v', "<leader>{", 'c{}<Esc>P')
vim.keymap.set('v', "<leader>[", 'c[]<Esc>P')
vim.keymap.set('n', '<leader>li', 'i[]()<Left><Left><Esc>a')
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<CR>', function()
  if vim.v.hlsearch == 1 then vim.cmd('nohlsearch') end
  return '<CR>'
end, { expr = true, silent = true })

local function build_with_cmake()
	  local build_command = "mkdir -p build && cd build && cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .. && make -j8"
	  local confirm = vim.fn.confirm("Build the C++ project?", "&Yes\n&No", 1)
	  if confirm == 1 then vim.cmd('AsyncRun ' .. build_command) else print("Build cancelled.") end
end

vim.keymap.set('n', '<leader>b', build_with_cmake, { desc = "Build with cmake" })

