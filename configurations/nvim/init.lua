-- Bootstrap Lazy Package Manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
                "git",
                "clone",
                "--filter=blob:none",
                "https://github.com/folke/lazy.nvim.git",
                "--branch=stable", -- latest stable release
                lazypath,
        })
end
vim.opt.rtp:prepend(lazypath)
vim.opt.signcolumn = "yes"
vim.opt.expandtab = true

local todo_config = {
        signs = true,      -- show icons in the signs column
        sign_priority = 8, -- sign priority
        -- keywords recognized as todo comments
        keywords = {
                FIX = {
                        icon = " ",                              -- icon used for the sign, and in search results
                        color = "error",                            -- can be a hex color, or a named color (see below)
                        alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
                        -- signs = false, -- configure signs for some keywords individually
                },
                TODO = { icon = " ", color = "info" },
                HACK = { icon = " ", color = "warning" },
                WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
                PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
                TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
        },
        gui_style = {
                fg = "NONE",   -- The gui style to use for the fg highlight group.
                bg = "BOLD",   -- The gui style to use for the bg highlight group.
        },
        merge_keywords = true, -- when true, custom keywords will be merged with the defaults
        -- highlighting of the line containing the todo comment
        -- * before: highlights before the keyword (typically comment characters)
        -- * keyword: highlights of the keyword
        -- * after: highlights after the keyword (todo text)
        highlight = {
                multiline = true,               -- enable multine todo comments
                multiline_pattern = "^.",       -- lua pattern to match the next multiline from the start of the matched keyword
                multiline_context = 10,         -- extra lines that will be re-evaluated when changing a line
                before = "",                    -- "fg" or "bg" or empty
                keyword = "wide",               -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
                after = "fg",                   -- "fg" or "bg" or empty
                pattern = [[.*<(KEYWORDS)\s*]], -- pattern or table of patterns, used for highlighting (vim regex)
                comments_only = true,           -- uses treesitter to match keywords in comments only
                max_line_len = 400,             -- ignore lines longer than this
                exclude = {},                   -- list of file types to exclude highlighting
        },
        -- list of named colors where we try to extract the guifg from the
        -- list of highlight groups or use the hex color if hl not found as a fallback
        colors = {
                error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
                warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
                info = { "DiagnosticInfo", "#2563EB" },
                hint = { "DiagnosticHint", "#10B981" },
                default = { "Identifier", "#7C3AED" },
                test = { "Identifier", "#FF00FF" }
        },
        search = {
                command = "rg",
                args = {
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                },
                -- regex that will be used to match keywords.
                -- don't replace the (KEYWORDS) placeholder
                --pattern = [[\b(KEYWORDS):]], -- ripgrep regex
                pattern = [[(KEYWORDS)]], -- match without the extra colon. You'll likely get false positives
        },
}


local setup_lsp_configs = function()
        local lspconfig = require('lspconfig')
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.resolveSupport = {
                properties = {
                        'documentation',
                        'detail',
                        'additionalTextEdits',
                }
        }
        lspconfig.pyright.setup {}
        lspconfig.clangd.setup {}
        lspconfig.cmake.setup {}
        lspconfig.vimls.setup {}
        lspconfig.dockerls.setup {}
        lspconfig.graphql.setup {}
        lspconfig.jdtls.setup {}
        lspconfig.jsonls.setup {}
        lspconfig.sqlls.setup {}
        lspconfig.azure_pipelines_ls.setup {}
        lspconfig.bashls.setup {}
        lspconfig.terraformls.setup {}
        lspconfig.rnix.setup {}
        lspconfig.rust_analyzer.setup {
                settings = {
                        ["rust-analyzer"] = {
                                imports = {
                                        granularity = {
                                                group = "module",
                                        },
                                        prefix = "self",
                                },
                                assist = {
                                        importEnforceGranularity = true,
                                        importPrefix = "crate"
                                },
                                cargo = {
                                        allFeatures = true,
                                        buildScripts = { enable = true }
                                },
                                completion = {
                                        autoimport = {
                                                enable = true
                                        }
                                },
                                procMacro = {
                                        enable = true
                                },
                                checkOnSave = {
                                        command = "clippy"
                                },
                                updates = {
                                        channel = "nightly"
                                }
                        }
                },
                capabilities = capabilities
        }
        lspconfig.lua_ls.setup {
                settings = {
                        Lua = {
                                diagnostics = {
                                        globals = { 'vim' }
                                }
                        }
                }
        }
        lspconfig.yamlls.setup {
                settings = {
                        yaml = {
                                format = {
                                        enable = true
                                },
                                keyOrdering = false,
                                validate = true,
                                schemaStore = {
                                        enable = true
                                }
                        }
                }
        }
        lspconfig.tsserver.setup {
                settings = {
                        typescript = {
                                format = {
                                        indentSize = 4,
                                        convertTabsToSpaces = true,
                                        trimTrailingWhitespace = true,
                                        semicolons = "remove"
                                }
                        }
                }
        }
end

-- Configuration
local telescope_conf = {
        defaults = {
                path_display = { "smart" },
                mappings = {
                        i = {
                                ["<C-e>"] = "move_selection_previous"
                        }
                }
        },
        pickers = {
                lsp_references = {
                        theme = "dropdown",
                },
                find_files = {
                        theme = "dropdown",
                        mappings = {
                                i = {
                                        ["<C-e>"] = "move_selection_previous",
                                }
                        },
                        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*", "--max-filesize", "100K" }
                }
        },
        extensions = {
                fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                }
        }
}

-- Nvim Tree Configuration
local function on_attach(bufnr)
        local api = require('nvim-tree.api')

        local function opts(desc)
                return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', '<TAB>', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))
        vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
        vim.keymap.set('n', 'R', api.tree.reload, opts('Refresh'))
        vim.keymap.set('n', 'y', api.fs.copy.node, opts('Copy'))
        vim.keymap.set('n', 'c', api.tree.change_root_to_node, opts('CD'))
        vim.keymap.set('n', 'p', api.fs.paste, opts('Paste'))
        vim.keymap.set('n', 'N', api.fs.create, opts('Create'))
end

local nvim_tree_conf = {
        sort_by = "case_sensitive",
        on_attach = on_attach,
        renderer = {
                group_empty = true,
        },
        filters = {
                dotfiles = true,
        },
}

local nvim_treesitter_conf = {
        indent = { enable = true },
        auto_install = false,
        highlight = { enable = true, disable = { '' }, additional_vim_regex_highlighting = false }
}

local lualine_conf = {
        options = {
                icons_enabled = true,
                theme = 'auto',
                component_separators = { left = '', right = '' },
                section_separators = { left = '', right = '' },
                disabled_filetypes = {
                        statusline = {},
                        winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = false,
                refresh = {
                        statusline = 100,
                        tabline = 1000,
                        winbar = 1000,
                }
        },
        sections = {
                lualine_a = { 'mode' },
                lualine_b = { 'branch', 'diff', 'diagnostics' },
                lualine_c = { 'filename' },
                lualine_x = { 'fileformat', 'filetype' },
                lualine_y = { 'lsp_progress' },
                lualine_z = { 'location' }
        },
        inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { 'filename' },
                lualine_x = { 'location' },
                lualine_y = {},
                lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {}
}

require("lazy").setup({
        {
                "williamboman/mason-lspconfig.nvim",
                config = function()
                        require("mason-lspconfig").setup {
                                automatic_installation = { exclude = { "rust-analyzer" } }
                        }
                        setup_lsp_configs()
                end,
                dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" }
        },
        {
                "hrsh7th/nvim-cmp",
                config = function()
                        local cmp = require 'cmp'
                        local icons = {
                                Array = '  ',
                                Boolean = '  ',
                                Class = '  ',
                                Color = '  ',
                                Constant = '  ',
                                Constructor = '  ',
                                Enum = '  ',
                                EnumMember = '  ',
                                Event = '  ',
                                Field = '  ',
                                File = '  ',
                                Folder = '  ',
                                Function = '  ',
                                Interface = '  ',
                                Key = '  ',
                                Keyword = '  ',
                                Method = '  ',
                                Module = '  ',
                                Namespace = '  ',
                                Null = ' ﳠ ',
                                Number = '  ',
                                Object = '  ',
                                Operator = '  ',
                                Package = '  ',
                                Property = '  ',
                                Reference = '  ',
                                Snippet = '  ',
                                String = '  ',
                                Struct = '  ',
                                Text = '  ',
                                TypeParameter = '  ',
                                Unit = '  ',
                                Value = '  ',
                                Variable = '  ',
                        }
                        require("luasnip/loaders/from_vscode").lazy_load()
                        cmp.setup({
                                snippet = {
                                        expand = function(args)
                                                require('luasnip').lsp_expand(args.body)
                                        end,
                                },
                                mapping = cmp.mapping.preset.insert({
                                        ['<CR>'] = cmp.mapping.confirm({ select = true }),
                                        ['<tab>'] = cmp.mapping.confirm({ select = true }),
                                        ['<C-e>'] = cmp.mapping.select_prev_item(),
                                        ['<C-k>'] = cmp.mapping.scroll_docs()
                                }),
                                formatting = {
                                        format = function(entry, item)
                                                item.kind = string.format('%s', icons[item.kind])
                                                item.menu = ({
                                                        buffer = '[Buffer]',
                                                        luasnip = '[Snip]',
                                                        nvim_lsp = '[LSP]',
                                                        nvim_lua = '[API]',
                                                        path = '[Path]',
                                                        rg = '[RG]',
                                                })[entry.source.name]

                                                return item
                                        end,
                                },
                                experimental = {
                                        ghost_text = true
                                },
                                sources = cmp.config.sources(
                                        {
                                                { name = "nvim_lsp", max_item_count = 20 },
                                                { name = "luasnip",  max_item_count = 5 },
                                                { name = "path" }
                                        },
                                        {
                                                { name = "buffer" }
                                        })
                        })
                end,
                lazy = false,
                dependencies = {
                        "hrsh7th/cmp-nvim-lsp",
                        "hrsh7th/cmp-buffer",
                        "hrsh7th/cmp-path",
                        "saadparwaiz1/cmp_luasnip"
                }
        },
        { "williamboman/mason.nvim",                  build = ":MasonUpdate", config = true },
        {
                "nvim-telescope/telescope.nvim",
                tag = "0.1.1",
                dependencies = { 'nvim-lua/plenary.nvim', 'sharkdp/fd', 'nvim-tree/nvim-web-devicons',
                        'nvim-treesitter/nvim-treesitter', 'nvim-telescope/telescope-ui-select.nvim' },
                config = function()
                        require("telescope").setup(telescope_conf)
                        require("telescope").setup({
                                extensions = {
                                        ["ui-select"] = {
                                                require("telescope.themes").get_dropdown {} }
                                }
                        })
                        require("telescope").load_extension("ui-select")
                        require("telescope").load_extension('fzf')
                end
        },
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        {
                "nvim-tree/nvim-tree.lua",
                opts = nvim_tree_conf,
                dependencies = { 'nvim-tree/nvim-web-devicons' }
        },
        {
                "L3MON4D3/LuaSnip",
                dependencies = { 'rafamadriz/friendly-snippets' },
                config = true,
                setup = function(args)
                        local snip = require 'luasnip'
                        snip.setup(args)
                        snip.loaders.from_vscode.lazy_load()
                end
        },
        { "nvim-lualine/lualine.nvim",       opts = lualine_conf, dependencies = { 'arkav/lualine-lsp-progress' } },
        { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
        'tpope/vim-fugitive',
        { 'lewis6991/gitsigns.nvim', config = true },
        'Mofiqul/dracula.nvim',
        'NLKNguyen/papercolor-theme',
        { "catppuccin/nvim",         name = "catppuccin" },
        'preservim/nerdcommenter',
        'ryanoasis/vim-devicons',
        'easymotion/vim-easymotion',
        {
                'jose-elias-alvarez/null-ls.nvim',
                config = function()
                        local null_ls = require("null-ls")
                        null_ls.setup {
                                sources = {
                                        null_ls.builtins.code_actions.gitsigns,
                                        null_ls.builtins.diagnostics.eslint,
                                },
                        }
                end,
        },
        { 'Darazaki/indent-o-matic', config = true },
        { 'gbprod/yanky.nvim',       config = true, opts = {} },
        {
                'simrat39/rust-tools.nvim',
                -- TODO currently type annotations don't work automatically because of mason-lspconfig  
                opts = {
                        inlay_hints = {
                                auto = true,
                        }
                }
        },
        { 'akinsho/toggleterm.nvim', config = true, opts = { open_mapping = [[<c-t>]] } },
        {
                "mickael-menu/zk-nvim",
                config = function()
                        require("zk").setup({
                                -- See Setup section below
                        })
                end
        },
        {
                "folke/todo-comments.nvim",
                dependencies = { "nvim-lua/plenary.nvim" },
                opts = todo_config
        },
        {
                'kylechui/nvim-surround',
                event = "VeryLazy",
                config = function()
                        require("nvim-surround").setup({})
                end
        }
})

require 'nvim-treesitter.configs'.setup(nvim_treesitter_conf)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

vim.filetype.add {
        extension = {
                tf = 'terraform'
        }
}

vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
vim.keymap.set("n", "<c-e>", "<Plug>(YankyCycleForward)")
vim.keymap.set("n", "<c-n>", "<Plug>(YankyCycleBackward)")

-- set theme
vim.cmd.colorscheme "catppuccin-frappe"
vim.diagnostic.config({ severity_sort = true })
