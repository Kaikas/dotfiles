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
vim.opt.signcolumn = "yes" -- deine vimrc hatte yes und später no; yes ist i.d.R. richtig
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
vim.opt.termguicolors = true -- sinnvoller als t_Co=256 in modernem nvim

-- Dein Mapping: <Space> löscht Highlight. In nvim besser über <leader>.
vim.g.mapleader = " "

-- ============================================================
-- Keymaps (Vimrc -> Lua)
-- ============================================================
local map = vim.keymap.set

map("n", "<F7>",  "<cmd>enew<CR>", { silent = true })
map("n", "<F8>",  "<cmd>bprevious<CR>", { silent = true })
map("n", "<F9>",  "<cmd>bnext<CR>", { silent = true })
map("n", "<F10>", "<cmd>bp | bd #<CR>", { silent = true })

-- Space clears search highlight (dein nnoremap <Space> :noh<Space><CR>)
map("n", "<Space>", "<cmd>nohlsearch<CR>", { silent = true })

-- Diff hunks navigation (dein <C-j>/<C-k> ]c/[c)
map("n", "<C-j>", "]c", { silent = true })
map("n", "<C-k>", "[c", { silent = true })

-- ä kopiert gesamte Datei ins System-Clipboard (in nvim: unnamedplus aktivieren + bleibt ok)
-- Hinweis: wenn du vim.opt.clipboard = "unnamedplus" setzt, reicht %y ohne "+. Ich lasse es explizit wie bei dir.
map("n", "ä", "<cmd>silent! %yank +<CR>", { silent = true })

-- ============================================================
-- Autocmds (Vimrc -> Lua)
-- ============================================================
local aug = vim.api.nvim_create_augroup

-- Jenkinsfile / Parameters / Seed_* -> groovy
local groovy = aug("ft_groovy_special", { clear = true })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = groovy,
  pattern = { "Jenkinsfile", "Parameters", "Seed_*" },
  command = "setfiletype groovy",
})

-- xml equalprg = xmllint ...
local xmlfmt = aug("ft_xml_equalprg", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = xmlfmt,
  pattern = "xml",
  callback = function()
    vim.opt_local.equalprg = "xmllint --format --recover - 2>/dev/null"
  end,
})

-- ============================================================
-- Diff tweaks (Vimrc -> Lua)
-- ============================================================
if vim.o.diff then
  vim.opt.diffopt:append({ "iwhite", "vertical" })

  -- Deine cterm colors 1:1. (Gilt primär für Terminal ohne TrueColor Themes.)
  vim.cmd([[
    highlight DiffAdd     ctermfg=none ctermbg=22
    highlight DiffChange  ctermfg=none ctermbg=24
    highlight DiffText    ctermfg=none ctermbg=18
    highlight DiffDelete  ctermfg=none ctermbg=52
  ]])

  -- Folds deaktivieren + alles öffnen, leicht verzögert
  local function disable_diff_folds()
    vim.cmd("silent! windo set nofoldenable")
    vim.cmd("silent! windo normal! zR")
  end

  local diffnofold = aug("diffnofold", { clear = true })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = diffnofold,
    callback = function()
      if vim.o.diff then
        vim.defer_fn(disable_diff_folds, 150)
      end
    end,
  })
end

-- ============================================================
-- Clipboard behaviour (Empfehlung)
-- ============================================================
-- Wenn du willst, dass jedes Yank automatisch ins System-Clipboard geht:
vim.opt.clipboard = "unnamedplus"

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
-- Plugins: replacements for your vim-plug list + your config
-- ============================================================
require("lazy").setup({
  -- NERDTree -> nvim-tree (de facto Standard-Äquivalent)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 60 },
        filters = { dotfiles = false }, -- ShowHidden=1
        git = { enable = true },
        actions = { open_file = { quit_on_open = true } },
      })
    end,
  },

  -- vim-airline -> lualine (modernes Äquivalent)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { icons_enabled = true },
      })
    end,
  },

  -- NerdCommenter -> Comment.nvim (leicht, sauber)
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
      -- deine Custom-Mappings: ,cc / ,cu
      -- Comment.nvim arbeitet mit toggles; wir mappen:
      vim.keymap.set("n", ",cc", function() require("Comment.api").toggle.linewise.current() end, { silent = true })
      vim.keymap.set("v", ",cc", function()
        local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
        vim.api.nvim_feedkeys(esc, "nx", false)
        require("Comment.api").toggle.linewise(vim.fn.visualmode())
      end, { silent = true })

      -- ",cu" separat als "uncomment" gibt’s in Comment.nvim nicht als eigenes API,
      -- weil es toggled. Wenn du echtes "nur uncomment" willst, sag’s: dann nehme ich mini.comment oder eine kleine helper-funktion.
      vim.keymap.set("n", ",cu", function() require("Comment.api").toggle.linewise.current() end, { silent = true })
      vim.keymap.set("v", ",cu", function()
        local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
        vim.api.nvim_feedkeys(esc, "nx", false)
        require("Comment.api").toggle.linewise(vim.fn.visualmode())
      end, { silent = true })
    end
  },

  -- VimTeX (du hast Settings + ü mapping)
  {
    "lervag/vimtex",
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"
    end,
    config = function()
      vim.keymap.set("n", "ü", "<cmd>VimtexCompile<CR>", { silent = true })
    end,
  },

  -- Copilot deaktiviert (du hattest g:copilot_enabled = v:false)
  -- Wenn du GitHub Copilot wirklich nutzt, sag Bescheid: dann setze ich das Plugin + disabled-Flag sauber.
})

-- ============================================================
-- NERDTree Toggle/Find behaviour -> nvim-tree equivalent
-- Deine Funktion: wenn im tree -> toggle, sonst find current file
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

