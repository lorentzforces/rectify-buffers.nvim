# rectify-buffers.nvim

_name subject to change._

Basic plugin to obviate the need to close and re-open Neovim entirely when working on projects.

In particular, this plugin aims to address the following use cases:

- You are editing a project managed by version control, and have just switched branches (or otherwise modified the tracked files on the filesystem).
- You are editing a project and have opened many buffers, and you would like to prune open buffers to only the files which you currently have open in a window.
