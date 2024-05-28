require("spaceman").setup({
  -- [OTHER SETTINGS]
  telescope_opts = require("telescope.themes").get_dropdown({
    prompt_title = "Cool Dropdown",
    results_title = "Items or Something",
    scroll_strategy = "limit",
  }),
})
