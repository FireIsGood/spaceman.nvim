# 👨‍🚀 spaceman.nvim 🚧

<p>
    <a href="https://dotfyle.com/plugins/FireIsGood/spaceman.nvim">
        <img src="https://dotfyle.com/plugins/FireIsGood/spaceman.nvim/shield" />
    </a>
</p>

> \[work\]spaceman\[ager\] for your workspaces

Provides a way to a open workspaces given the parent directories or specific workspaces.

- [Installation](#installation)
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

If you have used Visual Studio Code, this is similar to their `File: Open Recent...` action.

And the obligatory usage video:

https://github.com/FireIsGood/spaceman.nvim/assets/109556932/8ab66d04-1970-4b13-96bc-553053c9183f

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

The spaceman.nvim plugin comes with all its bindings and automatic features disabled by default. It is highly
recommended to enable sessions if you do not already have a plugin to manage them as shown above.

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
  use_sessions = true,         -- Whether to use sessions (RECOMMENDED TO ENABLE)
  rename_function = nil,       -- Function to rename your folders
  adapter = "telescope",       -- Which adapter to use, either "telescope" or "vim-ui" (for compatibility)
  hooks = {                    -- Hooks of a single Vim command, a table of vim commands, a Lua function, or nil
    before_move = nil,         -- Before changing directory
    after_move = nil,          -- After changing directory
  },
  telescope_opts = nil,        -- Options to pass to the telescope window
  data_path = vim.fn.stdpath("data") .. "/spaceman_data.json", -- Stores recently used workspaces
  sessions_path = vim.fn.stdpath("data") .. "/sessions",       -- Stores sessions
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

### Using hooks

Hooks can be either a string with a single command, a table of strings of commands, or a function to be run.

```lua
require("spaceman").setup({
  -- [OTHER SETTINGS]
  hooks = {
    -- before_move = "noh"                  -- A single command (string)
    before_move = { "noh", "echo 'bye'" }   -- A table of commands (strings)
    after_move = function() print("hi") end -- A function
  }
})
```

### Using custom keymaps

You can either use the User Commands or the Lua API.

```lua
-- User commands
map("n", "<leader>oj", ":Spaceman", { desc = "Open workspaces" })
map("n", "<leader>ok", ":SpacemanDirectory", { desc = "Open directories" })
map("n", "<leader>ol", ":SpacemanCount", { desc = "Count workspaces" })

-- Lua API
map("n", "<leader>oj", require("spaceman").open_workspaces, { desc = "Open workspaces" })
map("n", "<leader>ok", require("spaceman").open_directories, { desc = "Open directories" })
map("n", "<leader>ol", require("spaceman").count_workspaces, { desc = "Count workspaces" })
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

### Use vim-ui Instead of Telescope

If you don't want to use telescope for any reason, you can explicitly switch to using the vim-ui menu. If you don't have
telescope installed and don't explicitly set the adapter here, you will get a warning every time you list workspaces.

```lua
require("spaceman").setup({
  -- [OTHER SETTINGS]
  adapter = "vim-ui",
})
```

### Saving the Data File and Sessions folder Elsewhere

The data file tracks timestamps for your recently used folders. The sessions folder holds your session files. If you
wanted to share these across machines, you can change where they is saved.

```lua
require("spaceman").setup({
  -- [OTHER SETTINGS]
  data_path = "~/Documents/sync-or-whatever/spaceman_data.json", -- Store the file in a sync folder
  sessions_path = "~/Documents/sync-or-whatever/sessions",       -- Store session files in a sync folder subdirectory
})
```

### With Sessions.nvim

**Sessions are already built-in to the plugin.** This is more for if you want different features or have existing
sessions through this plugin.

```lua
require("spaceman").setup({
  -- [OTHER SETTINGS]
  use_sessions = false,
  hooks = {
    before_move = { "SessionsStop" },
    after_move = { "SessionsLoad" },
  },
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
    ├── sessions.lua        # Session saving and loading
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
- [projections.nvim](https://github.com/GnikDroy/projections.nvim) similar style with pattern matching, but more config

For more plugins in that vein, check out the [Telescope Extensions wiki](https://github.com/nvim-telescope/telescope.nvim/wiki/Extensions)

## Contributing

Feel free to make issues or pull requests!

## License

[MIT](https://choosealicense.com/licenses/mit/)
