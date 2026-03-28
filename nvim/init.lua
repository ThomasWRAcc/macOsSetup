-- Bootstrap lazy.nvim automatically
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


-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.termguicolors = true

-- Leader key
vim.g.mapleader = " "

-- Keymaps
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<leader>e", ":Ex<CR>")
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "kj", "<Esc>")

local accept_copilot = 'copilot#Accept("<CR>")'

-- Multiple key combinations pointing to the same action
for _, key in ipairs({ "<C-J>", "<C-Space>", "<S-Space>" }) do
    vim.keymap.set("i", key, accept_copilot, { expr = true, silent = true })
end


-- Setup lazy.nvim
require("lazy").setup({
    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local ok, ts = pcall(require, "nvim-treesitter.configs")
            if not ok then return end
            ts.setup({
                ensure_installed = { "lua", "python", "bash", "markdown", "json", "yaml" },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    -- Mason for LSP, formatters, linters
    { "williamboman/mason.nvim",          config = true },
    { "williamboman/mason-lspconfig.nvim" },

    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
        config = function()
            local mason_lspconfig = require("mason-lspconfig")
            mason_lspconfig.setup({
                ensure_installed = { "pyright", "lua_ls", "bashls", "marksman", "jsonls", "yamlls" }
            })

            -- LSP keymaps
            local on_attach = function(client, bufnr)
                local opts = { noremap = true, silent = true }
                local buf_set_keymap = function(mode, lhs, rhs)
                    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
                end

                buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
                buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
                buf_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
                buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
                buf_set_keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
                buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>")
            end

            local servers = { "pyright", "lua_ls", "bashls", "marksman", "jsonls", "yamlls" }
            for _, server in ipairs(servers) do
                local ok, lsp = pcall(require, "lspconfig")
                if ok and lsp[server] then
                    local opts = { on_attach = on_attach }
                    if server == "lua_ls" then
                        opts.settings = { Lua = { diagnostics = { globals = { "vim" } } } }
                    end
                    lsp[server].setup(opts)
                end
            end
        end
    },

    -- nvim-cmp
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "L3MON4D3/LuaSnip" },

    -- Copilot
    {
        "github/copilot.vim",
        config = function()
            vim.g.copilot_no_tab_map = true
            vim.g.copilot_assume_mapped = true
        end
    },
    {
        "zbirenbaum/copilot-cmp",
        dependencies = { "nvim-cmp" },
        config = function()
            require("copilot_cmp").setup({
                method = "getCompletionsCycling",
            })
        end
    },
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>")
            vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>")
        end
    },

    -- Required dependency for none-ls
    { "nvim-lua/plenary.nvim" },

    -- None-ls (formatter/linter bridge, maintained fork of null-ls)
    {
        "nvimtools/none-ls.nvim",
        dependencies = { "plenary.nvim" },
        config = function()
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.black,
                    null_ls.builtins.formatting.isort,
                    null_ls.builtins.formatting.shfmt,
                    null_ls.builtins.formatting.prettier,
                },
                on_attach = function(client, bufnr)
                    if client.supports_method("textDocument/formatting") then
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            buffer = bufnr,
                            callback = function()
                                vim.lsp.buf.format({ bufnr = bufnr })
                            end,
                        })
                    end
                end,
            })
        end,
    },

    -- Auto-install formatters/linters via Mason
    {
        "jay-babu/mason-null-ls.nvim",
        dependencies = { "williamboman/mason.nvim", "nvimtools/none-ls.nvim" },
        config = function()
            require("mason-null-ls").setup({
                ensure_installed = { "black", "isort", "shfmt", "prettier" },
                automatic_installation = true,
            })
        end,
    },
})

-- CMP setup
local cmp = require("cmp")
cmp.setup({
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "copilot" },
    }),
    completion = {
        autocomplete = { require("cmp").TriggerEvent.TextChanged }, -- <-- must be table
        completeopt = "menu,menuone,noselect",
    },
})
