local defaultAttach = function(client, bufnr)
	if client.server_capabilities.documentSymbolProvider then
		require("nvim-navic").attach(client, bufnr)
	end
end

local hasCapability = require("utils.lsp").hasCapability

local capabilities = require("blink.cmp").get_lsp_capabilities()
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
}

for lsp, config in pairs(require("utils.lsp.configs")) do
    config.capabilities = capabilities
    config.on_attach = config.on_attach or defaultAttach
    require("lspconfig")[lsp].setup(config)
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local map = require("core.keymaps").map
        for _, keys in ipairs(require("utils.lsp.keymaps")) do
            if not keys.has or hasCapability(ev.buf, keys.has) then
                local opts = keys.opts
                opts.silent = opts.silent ~= false
                opts.buffer = ev.buf
                map(keys.mode, keys.key, keys.command, opts)
            end
        end
        vim.diagnostic.config({
            virtual_text = false,
            severity_sort = true,
        })
    end,
})

