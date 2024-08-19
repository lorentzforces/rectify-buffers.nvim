# rectify-buffers.nvim

_name subject to change._

Basic plugin to obviate the need to close and re-open Neovim entirely when working on projects.

In particular, this plugin aims to address the following use cases:

- You are editing a project managed by version control, and have just switched branches (or otherwise modified the tracked files on the filesystem).
- You are editing a project and have opened many buffers, and you would like to prune open buffers to only the files which you currently have open in a window.

### Setup

In your lua init files, call the `setup` function. _E.g._:

```lua
require('rectify-buffers').setup()
```

This plugin creates the user command `RectifyBuffers`. Running `RectifyBuffers` will _delete_ any file-based buffers which are associated with a file which exists on disk, and _are not_ currently associated with a window. It will _reload_ any file-based buffers which are associated with a file which exists on disk, and which _are_ currently associated with a window (discarding any local changes in the buffer). Buffers which are not associated with an existing file on disk, or which are other "ephemeral" buffer types (like terminals and help) will be untouched.

This plugin also creates the user command `RectifyBuffersDebug`, which will log out all buffers with the intended action that `RectifyBuffers` would take, along with debug information about each buffer.

### Configuration

The `setup` function accepts a single parameter, which can be `nil`, or a table containing configuration settings. The list of settings is detailed here (actual values in the structure are the defaults):

```lua
local rectify_buffers = require('rectify-buffers')
rectify_buffers.setup({

    -- A user-defined function to be run after buffers are refreshed when
    -- `RectifyBuffers` is invoked, e.g. reloading an LSP. This function will
    -- receive no arguments.
    -- `user_function` may also be a string, in which case it is interpreted as
    -- a vimscript command to be run via vim.cmd
    --
    -- Examples:
    --   user_function = function() assert(true, 'great!') end,
    --   user_function = 'let g:rectified = "true"',
    user_function = nil,

})
```

## Requirements

- an internet connection to download test dependencies (only necessary if dependencies have changed or this is first-time setup)
- a `make` installation. This project is built with GNU make v4; full compatibility with other versions of make (such as that shipped by Apple) is not guaranteed.

> _Note: running with `make` is not strictly necessary. Reference the provided `Makefile` for typical development commands._

## Testing

Run `make test` in the project's root directory. When this is run for the first time, it will initialize all dependencies needed for testing.

To initialize dependencies (required for testing), run `make init` in the project's root directory to initialize the `deps` directory.

> Tests were built using [both the guidance and excellent framework provided by `mini.nvim`.](https://github.com/echasnovski/mini.nvim/blob/main/TESTING.md)

## Current project to-dos (in no particular order):

- Use this a bit to shake down bugs.
- Evaluate whether the plugin should unconditionally reload/delete modified buffers like it currently does, or if it should have two commands: one which refuses to reload or delete any modified buffers, and one which will happily do it (the equivalent of passing a `--force` option to programs).
- Add a help page for the plugin.
