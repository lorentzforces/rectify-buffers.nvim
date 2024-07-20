# rectify-buffers.nvim

_name subject to change._

Basic plugin to obviate the need to close and re-open Neovim entirely when working on projects.

In particular, this plugin aims to address the following use cases:

- You are editing a project managed by version control, and have just switched branches (or otherwise modified the tracked files on the filesystem).
- You are editing a project and have opened many buffers, and you would like to prune open buffers to only the files which you currently have open in a window.

## Testing

Run `make test` in the project's root directory. When this is run for the first time, it will initialize all dependencies needed for testing.

To initialize dependencies (required for testing), run `make` in the project's root directory to initialize the `deps` directory.

> Tests were built using [both the guidance and excellent framework provided by `mini.nvim`.](https://github.com/echasnovski/mini.nvim/blob/main/TESTING.md)

> _Note: running with `make` is not strictly necessary. Reference the provided `Makefile` for typical development commands._
