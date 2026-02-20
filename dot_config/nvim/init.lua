-- ~/.config/nvim/init.lua

-- ============================================================
-- Basic options 
-- ============================================================
vim.opt.encoding = "utf-8"
vim.opt.hidden = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.cmdheight = 2
vim.opt.updatetime = 300
vim.opt.shortmess:append("c")
vim.opt.signcolumn = "yes"
vim.opt.number = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.hlsearch = true
vim.opt.list = true
vim.opt.listchars = { tab = ">-" }
vim.opt.wrap = false
vim.opt.mouse = "v"
vim.opt.errorbells = false
vim.opt.visualbell = false
vim.opt.belloff = "all"
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"


-- ============================================================
-- Keymaps
-- ============================================================
local map = vim.keymap.set

-- F7: new buffer, F8,9: navigate buffers, F10: close buffer
map("n", "<F7>",  "<cmd>enew<CR>", { silent = true })
map("n", "<F8>",  "<cmd>bprevious<CR>", { silent = true })
map("n", "<F9>",  "<cmd>bnext<CR>", { silent = true })
map("n", "<F10>", "<cmd>bp | bd #<CR>", { silent = true })

-- Space clears search highlight
map("n", "<Space>", "<cmd>nohlsearch<CR>", { silent = true })

-- Copy whole file to clipboard
map("n", "ä", "<cmd>silent! %yank +<CR>", { silent = true })

-- ============================================================
-- Plugins: lazy.nvim bootstrap
-- ============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================
-- Plugins
-- ============================================================
require("lazy").setup({
  -- nvim-tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 60 },
        filters = { dotfiles = false },
        git = { enable = true },
        actions = { open_file = { quit_on_open = true } },
      })
    end,
  },
  -- lualine 
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { icons_enabled = true },
      })
    end,
  },
  -- rose-pine
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
  },
  -- chezmoi
  {
    "alker0/chezmoi.vim",
    lazy = false,
  },
  -- python editor
  {
    "neovim/nvim-lspconfig",
  },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright" }
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
  -- Completion
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },


})

-- ============================================================
-- Cheat Sheet
-- ============================================================
vim.api.nvim_create_autocmd("VimEnter", {
 callback = function()
   -- Nur wenn nvim OHNE Dateiparameter gestartet wurde
   if vim.fn.argc() == 0 then
     vim.cmd("edit ~/.config/nvim/cheatsheet.md")
   end
 end,
})


-- ============================================================
-- Theme
-- ============================================================
vim.cmd.colorscheme("rose-pine-moon")
vim.api.nvim_set_hl(0, "Normal", {
  bg = "#1b1f2b",
})
vim.api.nvim_set_hl(0, "NormalNC", {
  bg = "#1b1f2b",
})

-- ============================================================
-- Python IDE
-- ============================================================
vim.g.mapleader = " "

vim.lsp.config("pyright", {
  on_attach = function(_, bufnr)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = bufnr, silent = true, desc = desc })
    end

    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("gi", vim.lsp.buf.implementation, "Go to implementation")
    map("gr", vim.lsp.buf.references, "Find references")

    map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "Document symbols")
    map("<leader>ws", require("telescope.builtin").lsp_workspace_symbols, "Workspace symbols")
  end,
})

vim.lsp.enable("pyright")

-- ============================================================
-- CMP: Autocomplete Setup
-- ============================================================
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body) -- Snippet Support
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),         -- manuell Vervollständigung auslösen
    ["<CR>"]       = cmp.mapping.confirm({ select = true }), -- Enter bestätigt
    ["<Tab>"]      = cmp.mapping.select_next_item(), -- Tab durch Vorschläge
    ["<S-Tab>"]    = cmp.mapping.select_prev_item(), -- Shift+Tab zurück
  }),
  sources = {
    { name = "nvim_lsp" },
  },
})



-- ============================================================
-- nvim-tree toggle
-- ============================================================
local function my_tree_toggle()
  local ft = vim.bo.filetype
  if ft == "NvimTree" then
    vim.cmd("NvimTreeToggle")
  else
    vim.cmd("NvimTreeFindFile")
  end
end

vim.keymap.set("n", "<C-n>", my_tree_toggle, { silent = true })

-- ============================================================
-- Comment madness deactivated
-- ============================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})

