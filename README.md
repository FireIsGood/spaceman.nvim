# worker.nvim

A simple, declarative workspace manager.

Given a list of parent directories to workspaces, this extension allows you to telescope their workspaces.

## Installation

### Dependencies

- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

### Options

```lua
-- lazy.nvim
{
  "FireIsGood/worker.nvim",
  config = function()
    require("worker-nvim").setup({
      directories = {
        "~/Documents/Programming",
        "~/Documents/Fishing",
        "~/Documents/Whatever_You_Want",
      },
    })
  end,
}

-- packer
use {
	"FireIsGood/pond.nvim",
	config = function ()
		require("worker-nvim").setup({
      directories = {
        "~/Documents/Programming",
        "~/Documents/Fishing",
        "~/Documents/Whatever_You_Want",
      },
    })
	end,
}
```

## Usage

Use the command, default keymap, or write your own call to the API.

| Command       | Default Keymap | API Call                                   | Description      |
| ------------- | -------------- | ------------------------------------------ | ---------------- |
| `:WorkerOpen` | `<leader>wo`   | `require("worker-nvim").list_workspaces()` | Open a workspace |

## Configuration

You must specify directories to search for workspaces in the setup function call.

```lua
-- default config
require("worker-nvim").setup({
  directories = {},
  sort_by_recent = true,
  use_default_keymaps = true,
  hooks = { -- Single Vim command, table of vim commands, Lua function, or nil
    before_move = nil,
    after_move = nil,
  },
  data_path = vim.fn.stdpath("data") .. "/worker-nvim_data.json", -- Stores recently used workspaces
})
```

Each entry in `directories` is expanded and normalized, so you can use `~` as short for your home directory.

Example setup:

```lua
require("worker-nvim").setup({
  directories = {
    "~/Documents/Programming",
    "~/Documents/Fishing",
    "~/Documents/Whatever_You_Want",
  },
  sort_by_recent = false,
  use_default_keymaps = false,
  hooks = {
    before_move = function() print("hi") end,
    after_move = { "nohlsearch", "norm gg" },
  },
})
```

## Non-goals

There are already many plugins to manage workspace folders based on file patterns, manual additions, or Git repositories. As
such, this project's goal is not to search based on those types of criteria, but specifically the single-depth children
of provided parent folders.

If you wish to have the non-goal features described above, consider these options:

- [project.nvim](https://github.com/ahmedkhalf/project.nvim) manages based on file patterns
- [workspaces.nvim](https://github.com/natecraddock/workspaces.nvim) manages workspaces manually
- [whaler.nvim](https://github.com/salorak/whaler.nvim) looks for git directories

For more plugins in that vein, check out the [Telescope Extensions wiki](https://github.com/nvim-telescope/telescope.nvim/wiki/Extensions)

## Contributing

Feel free to make issues or pull requests!
