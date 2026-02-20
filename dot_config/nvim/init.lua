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

