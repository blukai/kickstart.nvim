-- set <space> as the leader key
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- see `:help vim.opt`
-- for more options, you can see `:help option-list`

-- line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- disable mouse
vim.opt.mouse = ''

-- sync clipboard between os and neovim.
vim.opt.clipboard = 'unnamedplus'

-- enable break indent
vim.opt.breakindent = true

-- save undo history
vim.opt.undofile = true

-- case-insensitive searching unless \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- disable signcolumn (shows warning letter and other shit next to the line no).
vim.opt.signcolumn = 'no'

-- decrease mapped sequence wait time (displays which-key popup sooner)
vim.opt.timeoutlen = 300

-- configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- preview substitutions live, as you type (doesn't work for plugins like tpope/vim-abolish)
vim.opt.inccommand = 'split'

-- higlights cursor line
vim.opt.cursorline = true
-- NOTE(blukai): you can also enable column highlight; but it's kind of
-- distracting most of the time. enable it on-demand :set cursorcolumn when you
-- need it.
-- vim.opt.cursorcolumn = true

-- minimal number of screen lines to keep above and below the cursor.
-- NOTE: this was set to 10, i did not like that so tried setting to 0.
-- NOTE: 10 is not that bad actually.
vim.opt.scrolloff = 10

-- see `:help vim.keymap.set()`

-- set highlight on search, but clear on pressing <esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- TIP: Disable arrow keys in normal mode
-- NOTE(blukai): uncommented following lines; also note that i did not find a way to move
-- cursor left and right without arrow keys in command mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- use ctrl+<hjkl> to switch between splits
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
-- this allows to resize vertical splits with ctrl+shift+direction
vim.keymap.set('n', '<C-S-h>', ':vertical resize -1<CR>', { silent = true })
vim.keymap.set('n', '<C-S-l>', ':vertical resize +1<CR>', { silent = true })
vim.keymap.set('n', '<C-S-j>', ':horizontal resize -1<CR>', { silent = true })
vim.keymap.set('n', '<C-S-k>', ':horizontal resize +1<CR>', { silent = true })

-- highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- install `lazy.nvim` plugin manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- this disables automatic line wripping during typing, super annoying! do it
-- manually with gw (or gq).
vim.opt.formatoptions = vim.opt.formatoptions - { 't', 'c' }

-- plugins
require('lazy').setup({
  -- detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- shows pending keybinds.
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
  },

  -- fuzzy finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      -- NOTE(blukai): telescope-live-grep-args.nvim extension allows to use
      -- ripgrep's arguments in search queries (for example specifying
      -- extensions).
      {
        'nvim-telescope/telescope-live-grep-args.nvim',
        -- This will not install any breaking changes.
        -- For major updates, this must be adjusted manually.
        version = '^1.0.0',
      },
    },
    config = function()
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          -- NOTE(blukai): following line loads telescope-live-grep-args.nvim
          -- extension
          ['live_grep_args'] = {},
        },
        defaults = {
          preview = {
            -- NOTE(blukai): this makes file search faster.
            -- see https://github.com/nvim-telescope/telescope.nvim/issues/1379#issuecomment-996590765
            treesitter = false,
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      -- NOTE(blukai): remap kickstart's default telescope grep to use extension
      -- that allows to specify ripgrep args
      -- vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sg', ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        end,
      })

      local servers = {
        -- NOTE(blukai): i sometimes open cpp files and this shit starts driving
        -- my cpu crazy providing absolutely no benefit whatsoever.
        -- clangd = {
        --   filetypes = { 'c', 'cpp' },
        -- },
        gopls = {
          -- NOTE(blukai): for some reason gopls is interfearing with tsx stuff,
          -- nanitf?
          filetype = { 'go' },
        },
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {},
          },
        },
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`tsserver`) will work just fine
        -- tsserver = {},
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        -- NOTE(blukai): added this; gofumpt can also be configured in gopls,
        -- but not golines. see other related comment for more info (search for
        -- golines).
        -- ----
        -- NOTE(blukai): disabled because i don't want to break existing (not my)
        -- projects
        'gofumpt',
        'goimports',
        'golines',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end

      -- NOTE(blukai): this is part of the snippet disablation effort.
      -- https://cmp.saghen.dev/configuration/snippets.html#disable-all-snippets
      -- :DisableAllSnippets
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities {
          textDocument = { completion = { completionItem = { snippetSupport = false } } },
        },
      })
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = {
          c = true,
          cpp = true,
        }
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- NOTE(blukai): added this instead of relying on gopls. the issue with
        -- gopls is that it runs go fmt (it has integration with gofumpt!),
        -- goimports, but it does not integrate with golines.
        -- ----
        -- NOTE(blukai): disabled this because i don't want to break existing
        -- (not my) go projects.
        go = { 'gofumpt', 'goimports', 'golines' },
        -- -- NOTE(blukai): this goes in hand with rustfmt in formatters down
        -- -- below.
        -- rust = { 'rustfmt' },
      },
      formatters = {
        -- NOTE(blukai): disabled this because i don't want to break existing (not my) go
        -- projects.
        golines = {
          -- golines will use goimports as base formatter by default which is slow.
          -- see https://github.com/segmentio/golines/issues/33
          prepend_args = { '--base-formatter=gofumpt', '--ignore-generated', '--max-len=100' },
        },
        -- rustfmt = {
        --   command = 'rustfmt',
        --   args = {
        --     -- NOTE(blukai): in rustfmt.toml i specify some settings that
        --     -- are available only on nightly. this enables neovim to run
        --     -- formatter with those settings.
        --     -- see: https://github.com/rust-lang/rust-analyzer/issues/3627
        --     '+nightly',
        --   },
        -- },
      },
    },
  },

  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    opts = {
      keymap = {
        preset = 'default',
      },
      completion = {
        -- NOTE(blukai): auto completins are super distructive
        trigger = {
          prefetch_on_insert = false,
          show_in_snippet = false,
          show_on_keyword = false,
          show_on_trigger_character = false,
          show_on_accept_on_trigger_character = false,
          show_on_insert_on_trigger_character = false,
        },
        documentation = { auto_show = false },
        menu = { auto_show = false },
      },
      sources = {
        -- NOTE(blukai): this is part of the snippet disablation effort.
        -- https://cmp.saghen.dev/configuration/snippets.html#disable-all-snippets
        -- :DisableAllSnippets
        transform_items = function(_, items)
          return vim.tbl_filter(function(item)
            return item.kind ~= require('blink.cmp.types').CompletionItemKind.Snippet
          end, items)
        end,
        default = {
          'lsp',
          'path',
        },
      },
      fuzzy = { implementation = 'lua' },
    },
  },

  {
    'stilla-theme/stilla.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
  },
  {
    'lunacookies/vim-plan9',
    priority = 1000, -- Make sure to load this before all the other start plugins.
  },
  {
    'tek256/simple-dark',
    priority = 1000, -- Make sure to load this before all the other start plugins.
  },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      -- NOTE(blukai): sr( will add whitepsace between ( and the selection; sr)
      -- will do the proper thing. see https://github.com/echasnovski/mini.nvim/issues/128
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = false }
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },

  {
    'smoka7/hop.nvim',
    opts = {},
    keys = {
      { 'f', '<cmd>HopWord<CR>' },
    },
  },

  {
    'shortcuts/no-neck-pain.nvim',
    lazy = false,
    opts = {
      width = 140,
      autocmds = {
        enableOnVimEnter = true,
      },
    },
  },

  -- NOTE(blukai): this allows to convert snake to camel case, and other
  -- variations..
  {
    'johmsalas/text-case.nvim',
    config = function()
      require('textcase').setup {}
      require('telescope').load_extension 'textcase'
    end,
    keys = { { '<leader>tc', mode = { 'v' }, '<cmd>TextCaseOpenTelescope<CR>', desc = 'Telescope text-case' } },
    cmd = { 'TextCaseOpenTelescope' },
  },

  -- NOTE(blukai): this is very cool shit for case-replicating search-replace
  -- with :%Subvert/a/b/
  { 'tpope/vim-abolish' },

  { 'godlygeek/tabular' },
}, {})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

-- NOTE(bluka): following disables command line (but it'll appear once you neter command mode)
vim.opt.cmdheight = 0

-- NOTE(blukai): this is (atm) for nicer comment wrapping (default seems to be 100, which is wider then i prefer)
vim.opt.textwidth = 80

-- NOTE(blukai): i really don't want to see wrapped lines. they confuse shit out
-- of me.
vim.opt.wrap = false

-- NOTE(blukai): following enables syntax highlighting in wgsl files.
-- https://www.reddit.com/r/neovim/comments/1bfzqic/comment/kv7l4ap/
vim.filetype.add {
  pattern = {
    ['.*%.wgsl'] = 'wgsl',
  },
}

-- NOTE(blukai): my shitty colorscheme configuration code ...

local function configure_colorscheme_pre(match)
  if match == 'stilla' then
    vim.o.background = 'dark'
    vim.g.stilla_italic = false
  elseif match == 'plan9' then
    vim.o.background = 'light'
  end
end

local function configure_colorscheme_post(match)
  if match == 'stilla' then
    -- NOTE(blukai): stilla's selection color is invisible to me
    vim.cmd.hi 'Visual guifg=White guibg=DarkBlue gui=none'
  elseif match == 'plan9' then
    vim.cmd.hi 'Comment cterm=NONE gui=NONE'
    vim.cmd.hi 'Folded cterm=NONE gui=NONE'
  elseif match == 'simple-dark' then
    -- list of unique shades of gray in this color scheme:
    -- #080808
    -- #0a0a0a
    -- #303030
    -- #585858
    -- #8a8a8a
    -- #bcbcbc
    -- #d0d0d0
    -- #eeeeee
    vim.cmd.hi 'Search       guibg=#8a8a8a guifg=#080808'
    -- NOTE(blukai): none of the colors listed above ^ were good for line/column
    -- highlights.
    vim.cmd.hi 'CursorLine   guibg=#1c1c1c'
    vim.cmd.hi 'CursorColumn guibg=#1c1c1c'
  elseif match == 'quiet' then
    vim.cmd.hi 'Comment gui=NONE'
  end
end

vim.api.nvim_create_autocmd('ColorSchemePre', {
  group = vim.api.nvim_create_augroup('UserColorSchemePre', {}),
  callback = function(ev)
    configure_colorscheme_pre(ev.match)
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('UserColorSchemePost', {}),
  callback = function(ev)
    configure_colorscheme_post(ev.match)
  end,
})

-- TODO: figure out how to make colorscheme that is selected via telescope
-- persist between restarts + update in all open neovim instances.
configure_colorscheme_pre 'simple-dark'
vim.cmd.colorscheme 'simple-dark'
configure_colorscheme_post 'simple-dark'

-- NOTE(blukai): disable semantic highlights globally
for _, group in ipairs(vim.fn.getcompletion('@lsp', 'highlight')) do
  vim.api.nvim_set_hl(0, group, {})
end
