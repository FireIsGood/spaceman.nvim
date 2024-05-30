# 👨‍🚀 spaceman.nvim 🚧

> Spaceman\[ager\] for your workspaces

Provides a way to a open workspaces given the parent directories or specific workspaces. This is specifically helpful if
you have a folder containing all your current projects and you wish to access any of those projects without writing the
names of each into a separate file.

- [Installation](#list-of-text-objects)
- [Usage](#configuration)
- [Configuration](#configuration)
- [Non-Goals](#non-goals)
- [Contributing](#contributing)
- [License](#license)

I developed this plugin to solve the very specific problem that I had to manually manage each of the workspaces. While
plugins like `workspaces.nvim` allow for setting directories, you must manually sync them each time and the directories
are stored away from the config. With this plugin, you can set a list of these parent folders and they will
automatically match the list of workspaces.

```text
~/
├── Documents/Projects/ # Point at this
│   ├── lua_projects
│   ├── c_projects
│   └── cool_website
└── dotfiles/           # And this
    ├── nvim            # But not these!
    ├── helix
    └── other_program
```

And the obligatory usage video:

https://github.com/FireIsGood/spaceman.nvim/assets/109556932/b9bb232e-2a7f-474d-9560-e247d0551772

## Installation

### Dependencies

- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) if you want to use the Telescope
  adapter

### Package Managers

A basic setup to turn your `~/Documents/Projects` folder into a workspace parent and enable the keymaps:

```lua
-- lazy.nvim
{
  "FireIsGood/spaceman.nvim",
  config = function()
    require("spaceman").setup({
      directories = {
        "~/Documents/Projects"
      },
      use_default_keymaps = true,
    })
  end,
}

-- packer
use {
  "FireIsGood/spaceman.nvim",
  config = function ()
    require("spaceman").setup({
      directories = {
        "~/Documents/Projects"
      },
      use_default_keymaps = true,
    })
  end,
}
```

For a full list of options and examples of using specific workspaces, see [Configuration](#configuration) below.

## Usage

> [!NOTE]
> Directory refers to the parent of multiple workspaces. Workspaces refers to specific workspaces

By default, only the command is registered. Otherwise, you can enable the default keymap or write your own API calls.

| Command              | Default Keymap | API Call                                       | Description                                                     |
| -------------------- | -------------- | ---------------------------------------------- | --------------------------------------------------------------- |
| `:Spaceman`          | `<leader>wo`   | `require("spaceman").open_workspaces()`        | Find and open a workspace                                       |
| `:SpacemanDirectory` | `<leader>wd`   | `require("spaceman").open_directories()`       | Find and open a directory (workspace parent) in the default app |
| `:SpacemanCount`     | `<leader>wc`   | `require("spaceman").count_workspaces()`       | Count the number of workspaces                                  |
|                      |                | `require("spaceman").api_open_workspace(path)` | Open a specific workspace                                       |

## Configuration

### Defaults

The default configuration is as follows:

```lua
-- default config
require("spaceman").setup({
  directories = {},            -- List of directories
  workspaces = {},             -- List of workspaces in the format { "name", "path" } or a string of the path
  sort_by_recent = true,       -- Whether to sort with recently opened workspaces in front
  use_default_keymaps = false, -- Whether to register keymaps
  use_default_hooks = true,    -- Whether to use default hooks (clear buffers, clear highlight)
  rename_function = nil,       -- Function to rename your folders
  adapter = "telescope",       -- Which adapter to use, either "telescope" or "vim-ui" (for compatibility)
  hooks = {                    -- Hooks of a single Vim command, a table of vim commands, a Lua function, or nil
    before_move = nil,         -- Before changing directory
    after_move = nil,          -- After changing directory
  },
  telescope_opts = nil,        -- Options to pass to the telescope window
  data_path = vim.fn.stdpath("data") .. "/spaceman_data.json", -- Stores recently used workspaces
})
```

### Basic Setup

Each entry in `directories` is a path to the parent of many workspaces. Each entry in `workspaces` is a specific
workspace with its custom name and the path.

All paths are expanded and normalized, so you can use `~` as short for your home directory.

Since opening the directory only changes directory to it, you will likely want to add hooks to delete buffers and/or set
up sessions.

Basic setup using directories, workspaces:

```lua
require("spaceman").setup({
  -- Workspace parents
  directories = {
    "~/Documents/Programming",
    "~/Documents/Fishing",
    "~/Documents/Whatever_You_Want",
  },

  -- Individual named workspaces
  workspaces = {
    { "Nvim-Data", "~/.local/share/nvim" },
    { "Config", "~/.config/nvim" },
    "~/Desktop",
  },

  -- Enable the default keymaps
  use_default_keymaps = true,
})
```

> [!NOTE]
> Workspaces linking to the same folder will override directories.

<details>
<summary>Further Examples</summary>

### With Sessions.nvim

```lua
require("spaceman").setup({
  -- [OTHER SETTINGS]
  hooks = {
    before_move = { "SessionsStop" },
    after_move = { "SessionsLoad" },
  },
})
```

### Using a Custom Rename Function

The custom rename function is run on ALL names, including custom workspace names.

```lua
require("spaceman").setup({
  -- [OTHER SETTINGS]
  rename_function = function(name)
    return string.gsub(" " .. name, "%W%l", string.upper):sub(2) -- Name to title case
    -- return string.gsub(name, "[-_]", " ")                     -- Underline and dash to space
    -- return string.gsub(name, "[-%s]", "_")                    -- Space and dash to underline
  end,
})
```

### Disable Sorting

You can disable sorting if you want a truly declarative config with no recent files. If you also don't want to save the
data file at all, you can change the path to `nil`

```lua
require("spaceman").setup({
  -- [OTHER SETTINGS]
  sort_by_recent = false,
  data_path = nil, -- Optional: don't save the data path at all
})
```

### Use vim-ui Instead of Telescope

If you don't want to use telescope for any reason, you can explicitly switch to using the vim-ui menu. If you don't have
telescope installed and don't explicitly set the adapter here, you will get a warning every time you list workspaces.

```lua
require("spaceman").setup({
  -- [OTHER SETTINGS]
  adapter = "vim-ui",
})
```

### Saving the Data File Elsewhere

The data file tracks timestamps for your recently used folders. If you wanted to share this across machines, you can
change where it is saved.

```lua
require("spaceman").setup({
  -- [OTHER SETTINGS]
  data_path = "~/Documents/sync-or-whatever/spaceman_data.json", -- Store in a sync folder
})
```

### Telescope Options

You may set a table of opts, either literally or through preset themes. See [Telescope
Themes](https://github.com/nvim-telescope/telescope.nvim#themes) or `:help telescope.setup()` more details on these
tables.

```lua
require("spaceman").setup({
  -- [OTHER SETTINGS]
  telescope_opts = require("telescope.themes").get_dropdown({
    prompt_title = "Cool Dropdown",
    results_title = "Items or Something",
    scroll_strategy = "limit",
  }),
})
```

</details>

## Local Development

<details>

<summary>If you want to work on the plugin yourself</summary>

First, clone the repo:

```bash
git clone git@github.com:FireIsGood/spaceman.nvim.git
```

Add the plugin's folder as a local plugin:

```lua
-- lazy.nvim
{
  dir = "~/Documents/Programming/spaceman.nvim",
  -- Your other settings
}

-- packer
use {
  "~/Documents/Programming/spaceman.nvim",
  -- Your other settings
}
```

The files are laid out as follows:

```text
lua/
└── spaceman/
    ├── adapters/
    │   ├── telescope.lua   # Telescope adapter
    │   └── vim-ui.lua      # Vim UI adapter
    ├── config.lua          # User configuration
    ├── default_commands    # User Command setup
    ├── default_keymaps     # Keymap setup
    ├── init.lua            # API and setup function
    ├── json.lua            # File system JSON helper functions
    ├── util.lua            # File system and general utilities
    └── workspace.lua       # General function calls (linked by API)
README.md
LICENSE
.stylua.toml
```

(Tree made with [tree.nathanfriend.io](https://tree.nathanfriend.io/))

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

## License

[MIT](https://choosealicense.com/licenses/mit/)
