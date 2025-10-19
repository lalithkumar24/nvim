local M = {}

M.on_attach = function(event)
	local client = vim.lsp.get_client_by_id(event.data.client_id)
	if not client then
		return
	end
	local bufnr = event.buf
	local keymap = vim.keymap.set
	local opts = {
		noremap = true,
		silent = true,
		buffer = bufnr,
	}

	-- native neovim keymaps
	keymap("n", "<leader>gD", "<cmd>lua vim.lsp.buf.definition()<CR>", opts) -- goto definition
	keymap("n", "<leader>gS", "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>", opts) -- goto definition in split
	keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts) -- Code actions
	keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts) -- Rename symbol
	keymap("n", "<leader>D", "<cmd>lua vim.diagnostic.open_float({ scope = 'line' })<CR>", opts) -- Line diagnostics (float)
	keymap("n", "<leader>d", "<cmd>lua vim.diagnostic.open_float()<CR>", opts) -- Cursor diagnostics
	keymap("n", "<leader>pd", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts) -- previous diagnostic
	keymap("n", "<leader>nd", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts) -- next diagnostic
	keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts) -- hover documentation

	-- fzf-lua keymaps
	keymap("n", "<leader>gd", "<cmd>FzfLua lsp_finder<CR>", opts) -- LSP Finder (definition + references)
	keymap("n", "<leader>gr", "<cmd>FzfLua lsp_references<CR>", opts) -- Show all references to the symbol under the cursor
	keymap("n", "<leader>gt", "<cmd>FzfLua lsp_typedefs<CR>", opts) -- Jump to the type definition of the symbol under the cursor
	keymap("n", "<leader>ds", "<cmd>FzfLua lsp_document_symbols<CR>", opts) -- List all symbols (functions, classes, etc.) in the current file
	keymap("n", "<leader>ws", "<cmd>FzfLua lsp_workspace_symbols<CR>", opts) -- Search for any symbol across the entire project/workspace
	keymap("n", "<leader>gi", "<cmd>FzfLua lsp_implementations<CR>", opts) -- Go to implementation

	-- Order Imports (if supported by the client LSP)
	if client:supports_method("textDocument/codeAction", bufnr) then
	-- === LSP keymaps ===
	keymap("n", "<leader>gD", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	keymap("n", "<leader>gS", "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>", opts)
	keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	keymap("n", "<leader>D", "<cmd>lua vim.diagnostic.open_float({ scope = 'line' })<CR>", opts)
	keymap("n", "<leader>d", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
	keymap("n", "<leader>pd", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
	keymap("n", "<leader>nd", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
	keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	-- === fzf-lua keymaps ===
	keymap("n", "<leader>gd", "<cmd>FzfLua lsp_finder<CR>", opts)
	keymap("n", "<leader>gr", "<cmd>FzfLua lsp_references<CR>", opts)
	keymap("n", "<leader>gt", "<cmd>FzfLua lsp_typedefs<CR>", opts)
	keymap("n", "<leader>ds", "<cmd>FzfLua lsp_document_symbols<CR>", opts)
	keymap("n", "<leader>ws", "<cmd>FzfLua lsp_workspace_symbols<CR>", opts)
	keymap("n", "<leader>gi", "<cmd>FzfLua lsp_implementations<CR>", opts)
	-- === Order Imports ===
	if client.supports_method("textDocument/codeAction") then
		keymap("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = {
					only = { "source.organizeImports" },
					diagnostics = {},
				},
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50)
		end, opts)
	end
	-- === DAP keymaps ===
	-- Languages with debugging configured: Python, C/C++, Rust, Zig, JavaScript, TypeScript
	local debug_clients = {
		"pylsp", "pyright", "basedpyright",  -- Python
		"clangd", "ccls",                     -- C/C++
		"rust_analyzer",                      -- Rust (note: underscore not dash)
		"zls",                                -- Zig
		"tsserver", "vtsls", "eslint",       -- JavaScript/TypeScript
	}
	local supports_debugging = false
	for _, lang in ipairs(debug_clients) do
		if client.name == lang then
			supports_debugging = true
			break
		end
	end
	if supports_debugging then
		local dap = require("dap")
		keymap("n", "<leader>dc", dap.continue, opts)           -- Start/Continue
		keymap("n", "<leader>do", dap.step_over, opts)          -- Step over
		keymap("n", "<leader>di", dap.step_into, opts)          -- Step into
		keymap("n", "<leader>du", dap.step_out, opts)           -- Step out
		keymap("n", "<leader>db", dap.toggle_breakpoint, opts)  -- Toggle breakpoint
		keymap("n", "<leader>dB", function()                    -- Conditional breakpoint
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, opts)
		keymap("n", "<leader>dr", dap.repl.open, opts)          -- Open REPL
		keymap("n", "<leader>dt", dap.terminate, opts)          -- Terminate session
	end
end

return M
