-- =======================================================================================================================================================================================================
-- init.lua ---------- init.lua ---------- init.lua ---------- init.lua ---------- init.lua ---------- init.lua ---------- init.lua ---------- init.lua ---------- init.lua ---------- init.lua ----------
-- =======================================================================================================================================================================================================

--[[

Neph Iapalucci's init.lua configuration for Neovim.

--]]

-- =======================================================================================================================================================================================================
-- Options ---------- Options ---------- Options ---------- Options ---------- Options ---------- Options ---------- Options ---------- Options ---------- Options ---------- Options ---------- Options -
-- =======================================================================================================================================================================================================
vim.opt.cursorline = true -- Highlight line that cursor is on
vim.opt.hlsearch = false -- Don't highlight searches
vim.opt.incsearch = true -- Incrementally highlight searches
vim.opt.mouse = nil -- Disable mouse
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Make line numbers relative to cursor position
vim.opt.wrap = false -- Disable word wrapping
vim.opt.tabstop = 4 -- Set tab size to 4
vim.opt.expandtab = false -- Dont replace tabs with spaces
vim.opt.shiftwidth = 4 -- Use tabstop for automatic tabs
vim.opt.showcmd = false -- Don't show keypressed
vim.opt.termguicolors = true -- Use true color in the terminal

-- Image.nvim - requires magick luarocks
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"
-- package.path = package.path .. ";" .. "/usr/lib/luarocks/rocks-5.4/luasocket/3.1.0-1"

-- Enable word wrapping for text files such as markdown or text
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
	end,
})

local filetypes = {
	["*.bash*"] = "bash",
	["*.ll"] = "llvm",
	["*.rasi"] = "rasi",
	["*.pest"] = "pest",
	["*.lotus"] = "lotus",
	["*.lang2"] = "lang2",
}

for pattern, filetype in pairs(filetypes) do
	vim.api.nvim_create_autocmd("BufRead", {
		pattern = pattern,
		callback = function()
			vim.bo.filetype = filetype
		end,
	})
end

vim.g.zig_fmt_autosave = false -- Disable Zig autoformatting which for some reason converts my enums into massive one-liners

vim.g.mapleader = " " -- Set leader to space - must be done before mappings

-- =======================================================================================================================================================================================================
-- Plugins ---------- Plugins ---------- Plugins ---------- Plugins ---------- Plugins ---------- Plugins ---------- Plugins ---------- Plugins ---------- Plugins ---------- Plugins ---------- Plugins -
-- =======================================================================================================================================================================================================

-- Bootstrapping: Automatically install Lazy.nvim if it isn't already
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

-- Start the plugin setup
require("lazy").setup(
	{

		-- file tree explorer
		{
			"nvim-neo-tree/neo-tree.nvim",
			branch = "v2.x",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-tree/nvim-web-devicons",
				"MunifTanjim/nui.nvim",
				{
					"3rd/image.nvim",
					opts = {
						backend = "ueberzug",
					},
				},
				{
					"folke/edgy.nvim",
					opts = {
						wo = {
							winbar = false,
						},
						bottom = {
							"toggleterm",
							size = 15,
						},
						left = {
							"neo-tree",
							size = 35,
						},
						animate = {
							enabled = false,
						},
					},
				},
			},
			config = function()
				require("nvim-web-devicons").setup({
					override = {
						-- Color overrides
						cs = { icon = "", color = "#8800EE", name = "Cs" },
						txt = { icon = "󰬴", color = "#999999", name = "Text" },

						-- Icons for files missing them
						ll = { icon = "", color = "#999999", name = "LLVM" },
						rkt = { icon = "λ", color = "#FF6666", name = "Racket" },
						asm = { icon = "", color = "#999999", name = "Assembly" },
						unity = { icon = "󰚯", color = "#DDDDDD", name = "Unity" },
						prefab = { icon = "󰚯", color = "#DDDDDD", name = "UnityPrefab" },
						obj = { icon = "󰆧", color = "#88AAFF", name = "WavefrontObject" },
						gltf = { icon = "󰆧", color = "#88AAFF", name = "GLTF" },
						blend = { icon = "󰂫", color = "#EA7600", name = "BlenderObject" },
						o = { icon = "󰘔", color = "#888888", name = "Object" },
						pest = { icon = "󰱯", color = "#2800C6", name = "Pest" },
						toggleterm = { icon = "", color = "#888888", name = "Terminal" },

						-- Icon overrides
						tex = { icon = "𝒙", color = "#999999", name = "LaTeX" },
					},
				})

				require("neo-tree").setup({
					close_if_last_window = true,
					enable_diagnostics = true,
					filesystem = {
						filtered_items = {
							visible = true,
							hide_gitignored = false,
							hide_dotfiles = false,
							never_show_by_pattern = {
								"*.meta",
							},
						},
						follow_current_file = {
							enabled = true,
						},
						use_libuv_file_watcher = true,
					},
					window = {
						position = "left",
						width = 30,
					},
					default_component_configs = {
						modified = {
							symbol = "󰧟 ",
						},
						git_status = {
							symbols = {
								added = "+",
								modified = "M",
								untracked = "+",
								deleted = "󰩹",
								renamed = "R",
								staged = "",
								unstaged = "",
								conflict = "",
								ignored = "󰈉",
							},
						},
					},
				})

				vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = "#88FF88" })
			end,
			keys = {
				{
					"<leader>ef",
					function()
						-- Files that indicate the root directory
						local root_files = {
							".git",
							"Cargo.toml",
							"Makefile",
							"package.json",
							".luarc.json",
							"pyproject.toml",
							"build.zig",
							"LICENSE",
							"index.html",
							"src",
						}

						-- Check if the directory is the root directory
						local function is_root_dir(dir_name)
							for _, name in ipairs(root_files) do
								if vim.fn.filereadable(dir_name .. "/" .. name) == 1 or vim.fn.isdirectory(dir_name .. "/" .. name) == 1 then
									return true
								end
							end
							return false
						end

						-- Locate the project root directory
						local current_directory = vim.fn.expand("%:p:h")
						local root_directory = current_directory
						while not is_root_dir(root_directory) do
							root_directory = vim.fn.fnamemodify(root_directory, ":h")
							if root_directory == "/" then
								root_directory = current_directory
								break
							end
						end

						-- Open Neotree in the project root directory
						vim.cmd("Neotree dir=" .. root_directory:gsub(" ", "\\ "))
					end,
					desc = "Neotree",
				},
			},
		},

		-- Pretty bottom status bar
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			config = function()
				require("lualine").setup({
					options = {
						component_separators = { left = "", right = "" },
						section_separators = { left = "", right = "" },
					},
					extensions = {
						"neo-tree",
						"lazy",
						"mason",
						-- "toggleterm",
						"trouble",
						"man",
					},
					sections = {
						-- Set mode name to Camelcase
						lualine_a = {
							{
								"mode",
								fmt = function(str)
									local mode = str:sub(1, 1) .. str:sub(2, str:len()):lower()
									local mode_overrides = {
										Normal = "Navigate",
										Visual = "Select",
										["V-line"] = "Select Line",
									}
									if mode_overrides[mode] then
										mode = mode_overrides[mode]
									end
									return mode
								end,
							},
						},

						-- Set the "B" section to be the file type
						lualine_b = {
							{
								"filetype",
								fmt = function(type)
									local formatted = type:sub(1, 1):upper() .. type:sub(2, type:len())
									local special_formats = {
										Cs = "C#",
										Cpp = "C++",
										Javscript = "JavaScript",
										Typescript = "TypeScript",
										Llvm = "LLVM",
										Json = "JSON",
										Jsonc = "JSON + Comments",
										Css = "CSS",
										Html = "HTML",
										Toml = "TOML",
										Typescriptreact = "TypeScript + Syntax Extension",
										Javascriptreact = "JavaScript + Syntax Extension",
										Gitignore = "Git Ignore",
										Scss = "Sass",
										Toggleterm = "Terminal",
									}

									if special_formats[formatted] then
										return special_formats[formatted]
									end

									return formatted
								end,
							},
						},

						-- Set the "C" section to be the Git branch name for rehabilitatoin
						lualine_c = {
							"branch",
						},

						-- Set the "Y" section to be the file name
						lualine_y = {
							{
								"filename",
								fmt = function()
									local path = vim.fn.expand("%:p")
									local cwd = vim.fn.getcwd()
									if path:sub(1, cwd:len()):gsub("\\", "/") == cwd:gsub("\\", "/") then
										path = path:sub(cwd:len() + 2, path:len())
									end
									if path == "/home/neph/.config/nvim/init.lua" then
										path = " Neovim Config"
									end

									if path:sub(1, #"term:") == "term:" then
										path = " Terminal"
									end
									return path
								end,
							},
						},

						-- Set "X" section to diagnostics
						lualine_x = {
							{
								"diagnostics",
								symbols = {
									warn = " ",
									error = " ",
									hint = " ",
									info = " ",
								},
							},
						},

						-- Set the "Z" section to be the line count
						lualine_z = {
							{
								"location",
								fmt = function()
									---@type number | string
									local lines = vim.fn.line("$")
									if lines > 1000 then
										lines = "‼ " .. lines
									end
									return lines .. " Lines"
								end,
							},
						},
					},
				})
			end,
		},

		-- Rust support
		{
			"rust-lang/rust.vim",
			dependencies = {
				"simrat39/rust-tools.nvim", -- Rust tooling
				"neovim/nvim-lspconfig", -- LSP Configuration
			},
			config = function()
				local mode = "dev"

				-- Switches between dev and release mode. Release mode has more strict lints that are annoying
				-- to deal with while developing, but are useful for production code.
				local function switch_mode()
					if mode == "dev" then
						mode = "release"
						require("lspconfig").rust_analyzer.setup({
							settings = {
								["rust-analyzer"] = {
									checkOnSave = {
										allFeatures = true,
										-- stylua: ignore start
										overrideCommand = {
											-- Run clippy linting on save
											"cargo",
											"clippy",
											"--workspace",
											"--message-format=json",
											"--all-targets",
											"--all-features",
											"--",

											-- Warnings: Enable Clippy to warn on all of the following groups:
											"-W", "clippy::pedantic", -- Very technical and just pedantic lints
											"-W", "clippy::nursery", -- Lints that have not yet been stabilized/made it into production clippy
											"-W", "clippy::cargo", -- Lints from the cargo command
											"-W", "clippy::correctness", -- Lints to check for code that is likely incorrect
											"-W", "clippy::perf", -- Lints for unperformant ways of doing things
											"-W", "clippy::style", -- Lints for bad code style or consistency
											"-W", "clippy::suspicious", -- Lints for things that you probably didn't mean to do / meant something else

											-- And enable these specific restrictive warnings
											"-W", "clippy::allow_attributes_without_reason", -- Warnings that are ignored for no reason
											"-W", "clippy::create_dir", -- create_dir instead of create_dir_all to create intermediate directories
											"-W", "clippy::deref_by_slicing", -- Slicing when dereferencing achieves the same
											"-W", "clippy::empty_structs_with_brackets", -- Empty structs with needless brackets instead of a semicolon
											"-W", "clippy::exit", -- Using the exit function at all
											"-W", "clippy::float_cmp_const", -- Comparing a float to a constant, which is subject to floating point precision
											"-W", "clippy::fn_to_numeric_cast_any", -- Casting a function pointer to a number
											"-W", "clippy::if_then_some_else_none", -- If-else's that could be written with bool::then
											"-W", "clippy::impl_trait_in_params", -- Using impl trait in parmeter instead of generic
											"-W", "clippy::indexing_slicing", -- Indexing or slicing which may panic instead of .get() which returns an option
											"-W", "clippy::integer_division", -- Dividing two integers without casting them to floats
											"-W", "clippy::let_underscore_must_use", -- Not using a value from a function marked as must_use
											"-W", "clippy::lossy_float_literal", -- Precision loss in floats
											"-W", "clippy::map_err_ignore", -- map_err() calls that discard the original error
											"-W", "clippy::mem_forget", -- Using mem::forget when the parameter implements Drop, meaning Drop isn't called
											"-W", "clippy::missing_assert_message", -- Asserting without an error message
											"-W", "clippy::missing_docs_in_private_items", -- Missing documentation comments
											"-W", "clippy::missing_enforced_import_renames", -- Missing import renames that are enforced
											"-W", "clippy::mixed_read_write_in_expression", -- Reading and writing a variable in the same expression which may cause confusion
											"-W", "clippy::multiple_inherent_impl", -- Multiple non-trait impls for the same struct
											"-W", "clippy::mutex_atomic", -- Using a Mutex when an Atomic will do the job
											"-W", "clippy::panic", -- Using the panic! macro
											"-W", "clippy::panic_in_result_fn", -- Using the panic! macro when a function returns a Result
											"-W", "clippy::print_stderr", -- Printing to stderr (should not be present in production code)
											"-W", "clippy::rc_mutex", -- Using Rc<Mutex>, in which Rc is not thread save but Mutex is
											"-W", "clippy::rest_pat_in_fully_bound_structs", -- Using a rest (..) pattern on a fully matched struct
											"-W", "clippy::same_name_method", -- Two methods with the same name on a struct due to traits
											"-W", "clippy::semicolon_outside_block", -- Semicolons that are placed inside of blocks (such as unsafe) instead of outside
											"-W", "clippy::shadow_reuse", -- Shadowing a variable to reuse it
											"-W", "clippy::shadow_same", -- Shadowing a variable with one with the same name
											"-W", "clippy::shadow_unrelated", -- Shadowing a variable and using it in an unrelated context
											"-W", "clippy::single_char_lifetime_names", -- Lifetime parameter names that are a single character (nondescriptive)
											"-W", "clippy::string_to_string", -- Converting a String to itself with .to_string()
											"-W", "clippy::suspicious_xor_used_as_pow", -- Using a XOR where pow() was probably intended
											"-W", "clippy::tests_outside_test_module", -- Using test functions outside of a module marked #[cfg(test)]
											"-W", "clippy::todo", -- The todo! macro (shouldn't be present in production code)
											"-W", "clippy::unimplemented", -- The unimplemented! macro (shouldn't be present in production code)
											"-W", "clippy::unnecessary_safety_comment", -- Safety comments on inherently safe operations
											"-W", "clippy::unnecessary_safety_doc", -- Safety documentation on inherently safe functions
											"-W", "clippy::unnecessary_self_imports", -- Unnecessarily importing "self" which does nothing
											"-W", "clippy::unneeded_field_pattern", -- Unnecessary fields in pattern matching instead of resting (..)
											"-W", "clippy::unreachable", -- The unreachable! macro (shouldn't be present in production code)
											"-W", "clippy::use_debug", -- Using the dbg! macro (shouldn't be present in production code)
											"-W", "clippy::verbose_file_reads", -- Reading a file with File::read_to or File::read_to_string instead of std::fs::read_to_string()

											-- BUT allow these that I deem stupid
											"-A", "clippy::multiple_crate_versions", -- Multiple versions of a dependency crate
											"-A", "clippy::module_name_repetitions", -- Repeating module name in identifiers
											"-A", "clippy::cast_precision_loss", -- Casting between numeric types where precision may be lost (such as an i32 to an i16)
											"-A", "clippy::cast_lossless",

											-- stylua: ignore end
										},
									},
								},
							},
						})
					else
						mode = "dev"
						require("lspconfig").rust_analyzer.setup({
							settings = {
								["rust-analyzer"] = {
									checkOnSave = {
										allFeatures = true,
										-- stylua: ignore start
										overrideCommand = {
											-- Run clippy linting on save
											"cargo",
											"clippy",
											"--workspace",
											"--message-format=json",
											"--all-targets",
											"--all-features",
											"--",

											-- Warnings: Enable Clippy to warn on all of the following groups:
											"-W", "clippy::pedantic", -- Very technical and just pedantic lints
											"-W", "clippy::nursery", -- Lints that have not yet been stabilized/made it into production clippy
											"-W", "clippy::cargo", -- Lints from the cargo command
											"-W", "clippy::correctness", -- Lints to check for code that is likely incorrect
											"-W", "clippy::perf", -- Lints for unperformant ways of doing things
											"-W", "clippy::style", -- Lints for bad code style or consistency
											"-W", "clippy::suspicious", -- Lints for things that you probably didn't mean to do / meant something else

											-- And enable these specific restrictive warnings
											"-W", "clippy::allow_attributes_without_reason", -- Warnings that are ignored for no reason
											"-W", "clippy::create_dir", -- create_dir instead of create_dir_all to create intermediate directories
											"-W", "clippy::deref_by_slicing", -- Slicing when dereferencing achieves the same
											"-W", "clippy::empty_structs_with_brackets", -- Empty structs with needless brackets instead of a semicolon
											"-W", "clippy::exit", -- Using the exit function at all
											"-W", "clippy::float_cmp_const", -- Comparing a float to a constant, which is subject to floating point precision
											"-W", "clippy::fn_to_numeric_cast_any", -- Casting a function pointer to a number
											"-W", "clippy::if_then_some_else_none", -- If-else's that could be written with bool::then
											"-W", "clippy::impl_trait_in_params", -- Using impl trait in parmeter instead of generic
											"-W", "clippy::indexing_slicing", -- Indexing or slicing which may panic instead of .get() which returns an option
											"-W", "clippy::integer_division", -- Dividing two integers without casting them to floats
											"-W", "clippy::let_underscore_must_use", -- Not using a value from a function marked as must_use
											"-W", "clippy::lossy_float_literal", -- Precision loss in floats
											"-W", "clippy::map_err_ignore", -- map_err() calls that discard the original error
											"-W", "clippy::mem_forget", -- Using mem::forget when the parameter implements Drop, meaning Drop isn't called
											"-W", "clippy::missing_assert_message", -- Asserting without an error message
											"-W", "clippy::missing_enforced_import_renames", -- Missing import renames that are enforced
											"-W", "clippy::mixed_read_write_in_expression", -- Reading and writing a variable in the same expression which may cause confusion
											"-W", "clippy::multiple_inherent_impl", -- Multiple non-trait impls for the same struct
											"-W", "clippy::mutex_atomic", -- Using a Mutex when an Atomic will do the job
											"-W", "clippy::panic", -- Using the panic! macro
											"-W", "clippy::panic_in_result_fn", -- Using the panic! macro when a function returns a Result
											"-W", "clippy::print_stderr", -- Printing to stderr (should not be present in production code)
											"-W", "clippy::rc_mutex", -- Using Rc<Mutex>, in which Rc is not thread safe but Mutex is
											"-W", "clippy::rest_pat_in_fully_bound_structs", -- Using a rest (..) pattern on a fully matched struct
											"-W", "clippy::same_name_method", -- Two methods with the same name on a struct due to traits
											"-W", "clippy::semicolon_outside_block", -- Semicolons that are placed inside of blocks (such as unsafe) instead of outside
											"-W", "clippy::shadow_reuse", -- Shadowing a variable to reuse it
											"-W", "clippy::shadow_same", -- Shadowing a variable with one with the same name
											"-W", "clippy::shadow_unrelated", -- Shadowing a variable and using it in an unrelated context
											"-W", "clippy::string_to_string", -- Converting a String to itself with .to_string()
											"-W", "clippy::suspicious_xor_used_as_pow", -- Using a XOR where pow() was probably intended
											"-W", "clippy::tests_outside_test_module", -- Using test functions outside of a module marked #[cfg(test)]
											"-W", "clippy::todo", -- The todo! macro (shouldn't be present in production code)
											"-W", "clippy::unimplemented", -- The unimplemented! macro (shouldn't be present in production code)
											"-W", "clippy::unnecessary_safety_comment", -- Safety comments on inherently safe operations
											"-W", "clippy::unnecessary_safety_doc", -- Safety documentation on inherently safe functions
											"-W", "clippy::unnecessary_self_imports", -- Unnecessarily importing "self" which does nothing
											"-W", "clippy::unneeded_field_pattern", -- Unnecessary fields in pattern matching instead of resting (..)
											"-W", "clippy::unreachable", -- The unreachable! macro (shouldn't be present in production code)
											"-W", "clippy::use_debug", -- Using the dbg! macro (shouldn't be present in production code)
											"-W", "clippy::verbose_file_reads", -- Reading a file with File::read_to or File::read_to_string instead of std::fs::read_to_string()

											-- BUT allow these that I deem stupid
											"-A", "clippy::multiple_crate_versions", -- Multiple versions of a dependency crate
											"-A", "clippy::module_name_repetitions", -- Repeating module name in identifiers
											"-A", "clippy::cast_precision_loss", -- Casting between numeric types where precision may be lost (such as an i32 to an i16)
											"-A", "clippy::cast_lossless",
											"-A", "clippy::missing_docs_in_private_items", -- Missing documentation comments

											-- stylua: ignore end
										},
									},
								},
							},
						})
					end
					print("Switched to " .. mode .. " mode")
				end

				vim.keymap.set("n", "<leader>lm", switch_mode, { silent = true })
			end,
			ft = "rust",
		},

		-- One Midnight theme syntax highlighting
		{
			"neph-iap/one-midnight.nvim",
			config = function()
				require("one-midnight").load()
			end,
		},

		-- Better UIs for menus and pickers
		{
			"stevearc/dressing.nvim",
			keys = {
				{ "<leader>ly", vim.lsp.buf.code_action, desc = "Accept Code Action" },
			},
		},

		-- Icon picker for writing icons such as     etc
		{
			"ziontee113/icon-picker.nvim",
			dependencies = {
				{ "nvim-telescope/telescope.nvim", opts = {} },
				"stevearc/dressing.nvim",
			},
			opts = {},
			keys = {
				{ "<leader>m", "<cmd>IconPickerNormal nerd_font_v3 alt_font symbols emoji<cr>", desc = "Insert Symbols" },
			},
		},

		-- Highlight colors in the editor such as #4a08a9, rgb(0, 255, 255), and hsl(150, 100, 50)
		{
			"brenoprata10/nvim-highlight-colors",
			opts = {},
		},

		-- Live markdown preview
		{
			"iamcco/markdown-preview.nvim",
			build = function()
				vim.schedule(function()
					vim.fn["mkdp#util#install"]()
				end)
			end,
		},

		-- Command line improvements and message tooltips
		{
			"folke/noice.nvim",
			dependencies = {
				"MunifTanjim/nui.nvim",
				"rcarriga/nvim-notify",
			},
			config = function()
				---@diagnostic disable-next-line missing-fields
				require("notify").setup({
					top_down = false, -- Send notifications to the bottom of the screen instead of the top
					background_colour = "#00000000", -- Background color
				})

				require("noice").setup({
					lsp = {
						override = {
							["vim.lsp.util.convert_input_to_markdown_lines"] = true,
							["vim.lsp.util.stylize_markdown"] = true,
							["cmp.entry.get_documentation"] = true,
						},
					},
					cmdline = {
						view = "cmdline", -- Keep Vim commands to standard bottom CMDLine instead of middle of screen
					},
					presets = {
						bottom_search = true,
						long_message_to_split = true,
						inc_rename = false,
						lsp_doc_border = true,
					},
				})
			end,
		},

		-- Todo diagnostic list
		{
			"folke/trouble.nvim",
			cmd = "TodoTrouble",
		},

		-- Highlight comments with  TODO: in them such as this, as well as FIXME and others, also creates a list of them
		{
			"folke/todo-comments.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
			opts = {},
		},

		-- Better UI for find and replace
		{
			"VonHeikemen/searchbox.nvim",
			dependencies = {
				{ "MunifTanjim/nui.nvim" },
			},
			keys = {
				{ "/", "<cmd>SearchBoxIncSearch<cr>", desc = "Search" },
			},
			opts = {
				popup = {
					position = {
						row = "0%",
						col = "100%",
					},
					win_options = {
						winhighlight = "Normal:Normal,FloatBorder:Normal",
					},
				},
			},
		},

		-- Indentation lines
		{
			"lukas-reineke/indent-blankline.nvim",
			config = function()
				local highlight = { "RainbowRed" }
				local hooks = require("ibl.hooks")
				hooks.register(hooks.type.HIGHLIGHT_SETUP, function() -- HACK: set RainbowRed to the indent line color
					vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#1E1E2E" })
				end)
				require("ibl").setup({
					indent = {
						highlight = highlight,
						char = "│",
					},
				})
			end,
		},

		-- Comment toggling
		{
			"terrortylor/nvim-comment",
			config = function()
				require("nvim_comment").setup()
			end,
			keys = {
				{ "<leader>c", "<cmd>CommentToggle<cr>", desc = "Comment Toggle" },
				{ "<leader>c", ":CommentToggle<cr>", desc = "Comment Toggle", mode = "v" },
			},
		},

		-- Auto-close parentheses, brackets, quotes, etc
		{
			"m4xshen/autoclose.nvim",
			config = function()
				require("autoclose").setup()
			end,
			event = "InsertEnter",
		},

		-- Live preview for LaTeX
		{
			"xuhdev/vim-latex-live-preview",
			opts = {},
			cmd = { "LLPStartPreview" },
		},

		-- Auto-generate licenses
		{
			"antoyo/vim-licenses",
			config = function()
				vim.g.license_copyright_holders_name = "Neph Iapalucci"
				vim.g.license_authors_name = "Neph Iapalucci"
			end,
			cmd = {
				"Affero",
				"Allpermissive",
				"Apache",
				"Boost",
				"Bsd2",
				"Bsd3",
				"Cc0",
				"Ccby",
				"Ccbysa",
				"Cecill",
				"Epl",
				"Gfdl",
				"Gpl",
				"Gplv2",
				"Isc",
				"Lgpl",
				"Mit",
				"Mitapache",
				"Mpl",
				"Uiuc",
				"Unlicense",
				"Verbatim",
				"Wtfpl",
				"Zlib",
			},
		},

		-- Autocomplete
		{
			"hrsh7th/nvim-cmp",
			dependencies = {
				"hrsh7th/cmp-cmdline", -- Autocomplete in command line
				"hrsh7th/cmp-buffer", -- Autocomplete for the buffer
				"hrsh7th/cmp-path", -- Autocomplete for file paths
				"L3MON4D3/LuaSnip", -- Snippets
				"onsails/lspkind.nvim", -- Icons in autocomplete
			},
			event = "InsertEnter",
		},

		-- Neovim development environment
		{
			"folke/neodev.nvim",
			ft = "lua",
		},

		-- Language tool manager
		{
			"neph-iap/forge.nvim",
			dependencies = {
				"nvim-treesitter/nvim-treesitter", -- Semantic highlighter
				"williamboman/mason.nvim", -- LSP Installer
				"neovim/nvim-lspconfig", -- LSP Configuration
				"williamboman/mason-lspconfig.nvim", -- LSP Configuration for Mason
				"hrsh7th/cmp-nvim-lsp", -- LSP integration with autocomplete
				"stevearc/conform.nvim", -- Autoformatter
			},
			opts = {},
		},

		-- Reopen file to last position
		{
			"ethanholz/nvim-lastplace",
			opts = {},
		},

		-- GitHub Copilot
		{
			"zbirenbaum/copilot.lua",
			cmd = "Copilot",
			event = "InsertEnter",
			config = function()
				require("copilot").setup({
					suggestion = {
						auto_trigger = true,
						keymap = {
							accept = "<Tab>",
						},
					},
				})
			end,
		},

		-- Show startup time statistics
		{
			"dstein64/vim-startuptime",
			cmd = "StartupTime",
			config = function()
				vim.g.startuptime_tries = 10
			end,
		},

		-- Color picker
		{
			"neph-iap/easycolor.nvim",
			dependencies = { "stevearc/dressing.nvim" },
			opts = {},
			keys = { { "<leader>b", "<cmd>EasyColor<cr>", desc = "Easy Color" } },
		},

		-- Open alternate files
		{
			"rgroli/other.nvim",
			main = "other-nvim",
			opts = {
				mappings = {
					-- Night Kitchen React
					{
						pattern = "(.*).js",
						target = "%1.module.scss",
					},
					{
						pattern = "(.*).module.scss",
						target = "%1.js",
					},
				},
			},
			keys = {
				{ "<leader>o", "<cmd>Other<cr>", desc = "Open Alternate File" },
			},
		},

		-- Transparent background
		{
			"xiyaowong/transparent.nvim",
			opts = {},
		},

		-- Terminal toggler
		{
			"akinsho/toggleterm.nvim",
			dependencies = {
				{
					"folke/edgy.nvim",
					opts = {
						wo = {
							winbar = false,
						},
						bottom = {
							"toggleterm",
							size = 15,
						},
						left = {
							"neo-tree",
							size = 35,
						},
						animate = {
							enabled = false,
						},
					},
				},
			},
			opts = {},
			keys = {
				{ "<C-`>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
			},
		},

		-- Pest support
		{
			"pest-parser/pest.vim",
			ft = "pest",
		},

		-- Incremental LSP rename
		{
			"smjonas/inc-rename.nvim",
			dependencies = { "stevearc/dressing.nvim" },
			opts = {
				input_buffer_type = "dressing",
			},
			keys = {
				{ "<leader>lr", ":IncRename ", desc = "Incremental Rename" },
			},
		},

		-- Lotus support
		-- {
		-- 	dir = "~/Documents/Coding/Developer Tools/Neovim Plugins/lotus.nvim",
		-- 	ft = "lotus",
		-- },

		-- Cargo
		-- {
		-- 	dir = "~/Documents/Coding/Developer Tools/Neovim Plugins/cargo.nvim",
		-- 	dependencies = {
		-- 		{
		-- 			"theHamsta/nvim_rocks",
		-- 			build = "pipx install hererocks && hererocks . -j2.1.0-beta3 -r3.0.0 && cp nvim_rocks.lua lua",
		-- 		},
		-- 		"stevearc/dressing.nvim",
		-- 	},
		-- 	ft = { "rust", "toml" },
		-- 	cmd = { "AddCrate" },
		-- 	opts = {},
		-- },

		{
			"akinsho/bufferline.nvim",
			dependencies = "nvim-tree/nvim-web-devicons",
			config = function()
				local function get_project_type()
					-- Files that indicate the root directory
					local root_files = {
						["Cargo.toml"] = "rs",
						["package.json"] = "js",
						[".luarc.json"] = "lua",
						["pyproject.toml"] = "py",
						["build.zig"] = "zig",
						["index.html"] = "html",
					}

					-- Check if the directory is the root directory
					local function is_root_dir(dir_name)
						for name, filetype in pairs(root_files) do
							if vim.fn.filereadable(dir_name .. "/" .. name) == 1 or vim.fn.isdirectory(dir_name .. "/" .. name) == 1 then
								return true, filetype
							end
						end
						return false, nil
					end

					-- Locate the project root directory
					local current_directory = vim.fn.expand("%:p:h")
					local root_directory = current_directory
					local is_root, filetype = is_root_dir(root_directory)
					while not (is_root or root_directory == "/") do
						root_directory = vim.fn.fnamemodify(root_directory, ":h") -- Set to parent dir
						if root_directory == "/" then
							root_directory = current_directory
							break
						end
						is_root, filetype = is_root_dir(root_directory)
					end

					return filetype, root_directory
				end

				local filetype, root_directory = get_project_type()

				local icon, color = require("nvim-web-devicons").get_icon_color("example", filetype)
				if not icon then
					icon = "*"
				end
				if not color then
					color = "#ffffff"
				end

				local last_dir = root_directory:sub(root_directory:find("/[^/]*$") + 1, root_directory:len())
				local special_directories = {
					["/home/neph/.config/nvim"] = "Neovim Configuration",
				}
				if special_directories[root_directory] then
					last_dir = special_directories[root_directory]
				end

				local neotree_bg = vim.api.nvim_exec("hi NeoTreeNormal", true):match("guibg=(#%S*)")
				vim.api.nvim_set_hl(0, "CustomBufferlineOffset", { fg = color, bg = neotree_bg })

				local buffers_opened = {}

				function buffers_opened:index_of(buffer)
					for i, buf in ipairs(self) do
						if buf == buffer then
							return i
						end
					end
					return nil
				end

				local bufferline = require("bufferline")

				bufferline.setup({
					options = {
						style_preset = {
							bufferline.style_preset.no_italic,
						},
						offsets = {
							{
								filetype = "neo-tree",
								text = icon .. " " .. last_dir,
								highlight = "CustomBufferlineOffset",
								text_align = "left",
							},
						},
						separator_style = { "", "" },
						show_buffer_close_icons = false,
						show_close_icon = false,
					},
					highlights = {
						fill = {
							bg = neotree_bg,
						},
						tab = {
							bg = neotree_bg,
						},
						background = {
							bg = neotree_bg,
						},
						tab_close = {
							bg = neotree_bg,
						},
						close_button = {
							bg = neotree_bg,
						},
						close_button_visible = {
							bg = neotree_bg,
						},
					},
				})

				-- -- Manual sorting wizardry - This enusres that the tabs are always sorted by most recently opened.
				-- -- Every time a buffer is opened, it is automatically made the first tab, and the rest are shifted
				-- -- to the right. Thus, the closest tabs are the most recently used.
				-- vim.api.nvim_create_autocmd("BufEnter", {
				-- 	callback = function(args)
				-- 		local state = require("bufferline.state")
				-- 		table.remove_value(buffers_opened, args.buf)
				-- 		table.insert(buffers_opened, args.buf)
				-- 		table.sort(state.components, function(a, b)
				-- 			local a_index = buffers_opened:index_of(a.id)
				-- 			local b_index = buffers_opened:index_of(b.id)
				-- 			return a_index > b_index
				-- 		end)
				-- 		for index, buf in ipairs(state.components) do
				-- 			buf.ordinal = index
				-- 		end
				-- 		state.custom_sort = require("bufferline.utils").get_ids(state.components)
				-- 		require("bufferline.ui").refresh()
				-- 	end,
				-- })
				--
				-- -- vim.keymap.set("n", "<S-h>", ":BufferLineCyclePrev<CR>", {}) -- Move to next buffer
				-- vim.keymap.set("n", "<S-h>", function()
				-- 	vim.cmd("BufferLineCyclePrev")
				-- 	vim.cmd("BufferLineCyclePrev")
				-- end, {})
				-- vim.keymap.set("n", "<S-l>", ":BufferLineCycleNext<CR>", {}) -- Move to previous buffer
			end,
			event = "VeryLazy", -- Required after NeoTreeNormal highlight group is loaded
		},

		{
			"mfussenegger/nvim-lint",
			config = function()
				require("lint").linters.lang2 = {
					name = "lang2",
					cmd = "lang2",
					args = {},
					stdin = false,
					stream = "both",
					ignore_exitcode = false,
					parser = function(output, bufnr)
						local diagnostics = {}
						for _, line in ipairs(vim.split(output, "\n")) do
							local line_number, column, severity, message = line:match("^Error: (%d+):(%d+):(%w+):(.*)")
							if line_number then
								table.insert(diagnostics, {
									bufnr = bufnr,
									lnum = tonumber(line_number),
									col = tonumber(column),
									severity = vim.diagnostic.severity.ERROR,
									message = message,
								})
							end
						end
						return diagnostics
					end,
				}

				require("lint").linters_by_ft = {
					lang2 = { "lang2" },
				}

				vim.api.nvim_create_autocmd({ "BufWritePost" }, {
					callback = function()
						require("lint").try_lint()
					end,
				})
			end,
		},

		{
			"lambdalisue/suda.vim",
			keys = {
				{ "<leader>w", "<cmd>SudaWrite<cr>" }
			}
		}
	},

	-- Options for lazy.nvim
	{
		ui = {
			wrap = false,
			colorscheme = { "onedark" },
			icons = {
				lazy = " ",
				loaded = "",
				start = "",
				cmd = "",
				event = "",
				not_loaded = "",
				plugin = "",
				source = "",
				config = "",
				require = "",
				ft = "",
			},
		},
	}
)

-- ==================================================================================================================================================================================
-- Mappings ---------- Mappings ---------- Mappings ---------- Mappings ---------- Mappings ---------- Mappings ---------- Mappings ---------- Mappings ---------- Mappings ---------
-- ==================================================================================================================================================================================

-- General
vim.keymap.set("n", "<leader>z", ":Lazy<CR>", { silent = true }) -- Open Lazy.nvim package manager
vim.keymap.set("n", "<leader>eu", ":wincmd p<CR>", { silent = true }) -- Unfocus file explorer
vim.keymap.set("n", "<leader>nc", ":NoiceDismiss<CR>", { silent = true }) -- Dismiss notifications
vim.keymap.set("n", "<C-v>", "i<C-v><Esc>", {}) -- Paste from clipboard in normal mode
vim.keymap.set("v", "<space>y", '"+y', {}) -- Copy to system clipboard
vim.keymap.set("n", "<space>p", '"+p', {}) -- Paste to system clipboard
vim.keymap.set("n", "j", "gj", {}) -- Move down by display line
vim.keymap.set("n", "k", "gk", {}) -- Move up by display line
vim.keymap.set("n", "d_", "dt_", {}) -- Delete to next underscore

-- Window Movement
vim.keymap.set("n", "<C-j>", "<C-w>j", {}) -- Move to window below
vim.keymap.set("n", "<C-k>", "<C-w>k", {}) -- Move to window above
vim.keymap.set("n", "<C-h>", "<C-w>h", {}) -- Move to window left
vim.keymap.set("n", "<C-l>", "<C-w>l", {}) -- Move to window right

-- Lsp Mappings
vim.keymap.set("n", "<leader>fr", ":Forge<CR>", { silent = true }) -- Open Forge.nvim
vim.keymap.set("n", "<leader>lh", vim.lsp.buf.hover, {}) -- Show hover information
vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, {}) -- Jump to definition
vim.keymap.set("n", "<leader>ln", vim.diagnostic.goto_next, {}) -- Go to next LSP diagnostic
vim.keymap.set("n", "<leader>lp", vim.diagnostic.goto_prev, {}) -- Go to previous LSP diagnostic
