# 👷 spaceman.nvim 🚧

> Spaceman\[ager\] for your workspaces

Provides a way to a open workspaces given the parent directories or specific workspaces.

- [Installation](#list-of-text-objects)
- [Usage](#configuration)
- [Configuration](#configuration)
- [Non-Goals](#non-goals)
- [Contributing](#contributing)

And the obligatory usage GIF:

## Installation

### Dependencies

- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

### Package Managers

You will need to customize the plugin for actual use, but this is the minimal setup to install:

```lua
-- lazy.nvim
{
  "FireIsGood/spaceman.nvim",
  config = function()
    require("spaceman").setup()
  end,
}

-- packer
use {
  "FireIsGood/spaceman.nvim",
  config = function ()
    require("spaceman").setup()
  end,
}
```

## Usage

By default, only the command is registered. Otherwise, you can enable the default keymap or write your own API calls.

| Command     | Default Keymap | API Call                                   | Description               |
| ----------- | -------------- | ------------------------------------------ | ------------------------- |
| `:Spaceman` | `<leader>wo`   | `require("spaceman").list_workspaces()`    | List workspaces           |
|             |                | `require("spaceman").open_workspace(path)` | Open a specific workspace |

## Configuration

> [!NOTE]
> Directory refers to the parent of multiple workspaces. Workspaces refers to specific workspaces

The default configuration is as follows:

```lua
-- default config
require("spaceman").setup({
  directories = {},            -- List of directories
  workspaces = {},             -- List of workspaces in the format { "name", "path" }
  sort_by_recent = true,       -- Whether to sort with recently opened workspaces in front
  use_default_keymaps = false, -- Whether to register keymaps
  rename_function = nil,       -- Function to rename your folders
  hooks = {                    -- Hooks of a single Vim command, a table of vim commands, a Lua function, or nil
    before_move = nil,         -- Before changing directory
    after_move = nil,          -- After changing directory
  },
  data_path = vim.fn.stdpath("data") .. "/spaceman_data.json", -- Stores recently used workspaces
})
```

Each entry in `directories` is a path to the parent of many workspaces. Each entry in `workspaces` is a specific
workspace with its custom name and the path.

All paths are expanded and normalized, so you can use `~` as short for your home directory.

Since opening the directory only changes directory to it, you will likely want to add hooks to delete buffers as seen in
below.

Example setup:

```lua
require("spaceman").setup({
  directories = {
    "~/Documents/Programming",
    "~/Documents/Fishing",
    "~/Documents/Whatever_You_Want",
  },
  workspaces = {
    { "Nvim-Data", "~/.local/share/nvim" },
    { "Config", "~/.config/nvim" },
  }
  use_default_keymaps = true,
  hooks = {
    before_move = { "nohlsearch", "silent %bdelete!" }
    after_move = function() print("We have arrived.") end,
  },
})
```

<details>
<summary>Further Examples</summary>

### With Sessions.nvim

```lua
require("spaceman").setup({
  -- Your workspaces and directories
  hooks = {
    before_move = { "noh","SessionsStop" ,"silent %bdelete!" },
    after_move = { "SessionsLoad" },
  },
})
```

### Using a Custom Rename Function

```lua
require("spaceman").setup({
  -- Your workspaces and directories
  use_default_keymaps = true,
  rename_function = function(name)
    return string.gsub(" " .. name, "%W%l", string.upper):sub(2) -- Name to title case
  end,
})
```

</details>

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
