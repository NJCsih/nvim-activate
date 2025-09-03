# nvim-activate

Displays an 'Activate Neovim' message in the bottom-right corner of the editor.

![Screenshot](https://raw.githubusercontent.com/tjkuson/misc-binaries/main/tjkuson/nvim-activate/screenshot.png)

## Installation

Install using your package manager of choice. Calling `require("nvim-activate").setup()` is optional (the plugin auto-initializes).

## Usage

### Commands

```vim
:NvimActivateShow
:NvimActivateHide
:NvimActivateToggle
```

### Configuration

```lua
-- Global disable
vim.g.nvimactivate_disable = true

-- Buffer-specific disable
vim.b.nvimactivate_disable = true
```

### Recipes

Hide after a delay on startup:

```vim
autocmd VimEnter * ++once lua vim.defer_fn(function()
  vim.g.nvimactivate_disable = true
  require("nvim-activate").hide()
end, 1500)
```

```lua
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.defer_fn(function()
      vim.g.nvimactivate_disable = true
      require("nvim-activate").hide()
    end, 1500)
  end,
})
```

Hide during Insert mode, show on exit:

```vim
autocmd InsertEnter * NvimActivateHide
autocmd InsertLeave * NvimActivateShow
```

```lua
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function() require("nvim-activate").hide() end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function() require("nvim-activate").show() end,
})
```

Enable only in specific filetypes (when globally disabled):

```vim
let g:nvimactivate_disable = v:true
augroup NvimActivateExamples
  autocmd!
  autocmd FileType python let b:nvimactivate_disable = v:false
augroup END
```

```lua
vim.g.nvimactivate_disable = true
local grp = vim.api.nvim_create_augroup("NvimActivateExamples", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = grp,
  pattern = { "python" },
  callback = function()
    vim.b.nvimactivate_disable = false
  end,
})
```
