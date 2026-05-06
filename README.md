# vim-svn

A Vim plugin for SVN version control with a lazygit-inspired panel layout using native Vim buffers and windows.

Press one key to see file status, preview diffs, browse logs, and execute SVN operations — all without leaving Vim.

## Features

- **Panel layout** — files, log, preview, and hint bar in a single view
- **Auto-preview** — preview panel updates as you move the cursor
- **Single-key shortcuts** — `d` for diff, `c` for commit, `r` for revert, etc.
- **Multi-mark** — mark files with `Space`, then batch operate
- **File status grouping** — files organized by Modified / Added / Deleted / Untracked / Conflicted
- **Log browser** — browse commit history with auto-preview of commit details
- **Context-sensitive hints** — bottom bar shows available keys for the active panel

## Layout

```
+---------------------------+-------------------------------+
|  Files (top-left)         |  Preview (right)              |
|  -- Modified ----------   |  auto-updates on cursor move  |
|  * [M]  src/tb_top.sv     |  shows diff or file content   |
|    [M]  src/env/agent.sv  |                               |
+---------------------------+                               |
|  Log (bottom-left)        |                               |
|  r12345  author  msg...   |                               |
+---------------------------+-------------------------------+
|  d:diff  c:commit  r:revert  a:add  SPACE:mark  q:quit    |
+------------------------------------------------------------+
```

## Requirements

- Vim 8.0+
- SVN client
- Optional: [delta](https://github.com/dandavison/delta) or [bat](https://github.com/sharkdp/bat) for syntax-highlighted diff preview

## Installation

### vim-plug

```vim
Plug 'maiyangzhan/vim-svn'
```

### Manual

```bash
cp -r plugin/* ~/.vim/plugin/
cp -r autoload/* ~/.vim/autoload/
cp -r doc/* ~/.vim/doc/
vim -c 'helptags ~/.vim/doc' -c 'q'
```

## Usage

| Key / Command | Action |
|---|---|
| `<Leader>s` | Open panel layout |
| `:Svn` | Same as above |

### Files Panel (top-left)

| Key | Action |
|---|---|
| `Space` | Toggle mark on current file |
| `d` | Show diff in preview |
| `c` | Commit marked/current files |
| `r` | Revert marked/current files |
| `a` | Add untracked files |
| `x` | Delete untracked files |
| `m` | Mark conflicted files as resolved |
| `R` | Refresh file list |
| `u` | Run `svn update` |
| `q` | Close all panels |

### Log Panel (bottom-left)

| Key | Action |
|---|---|
| `d` / `Enter` | Show full revision diff in preview |
| `R` | Refresh log |
| `q` | Close all panels |

### Preview Panel (right)

Scrollable with `j`/`k`/`Ctrl-d`/`Ctrl-u`. Press `q` to close.

### Navigation

Use `Ctrl-w` + `h`/`j`/`k`/`l` to move between panels.

## Configuration

```vim
" Trigger key (default: <Leader>s)
let g:svn_map = '<Leader>s'

" Number of log entries to show (default: 50)
let g:svn_log_limit = 50

" Use delta/bat for diff highlighting (default: 1)
let g:svn_diff_highlight = 1
```

## License

MIT
