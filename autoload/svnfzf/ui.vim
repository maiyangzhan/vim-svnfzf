" autoload/svnfzf/ui.vim — Window layout management

let s:winids = {}
let s:bufnrs = {}
let s:is_open = 0
let s:prev_winid = 0

function! svnfzf#ui#is_open() abort
  return s:is_open
endfunction

function! svnfzf#ui#open() abort
  if s:is_open
    call win_gotoid(s:winids.files)
    return
  endif

  let s:prev_winid = win_getid()

  " Create hint bar at very bottom
  botright 1new
  let s:winids.hints = win_getid()
  let s:bufnrs.hints = bufnr('%')
  call s:setup_panel_buf('svnfzf://hints')
  setlocal winfixheight

  " Go back up, create files panel
  wincmd k
  leftabove vnew
  let s:winids.files = win_getid()
  let s:bufnrs.files = bufnr('%')
  call s:setup_panel_buf('svnfzf://files')

  " Create log panel below files
  belowright new
  let s:winids.log = win_getid()
  let s:bufnrs.log = bufnr('%')
  call s:setup_panel_buf('svnfzf://log')

  " Preview panel is the original window
  call win_gotoid(s:prev_winid)
  enew
  let s:winids.preview = win_getid()
  let s:bufnrs.preview = bufnr('%')
  call s:setup_panel_buf('svnfzf://preview')

  " Set proportions
  call win_gotoid(s:winids.files)
  execute 'vertical resize ' . (&columns * 45 / 100)
  call win_gotoid(s:winids.log)
  execute 'resize ' . (&lines * 35 / 100)

  " Focus on files panel
  call win_gotoid(s:winids.files)

  let s:is_open = 1

  augroup svnfzf_ui
    autocmd!
    autocmd BufEnter svnfzf://files call svnfzf#hints#update('files')
    autocmd BufEnter svnfzf://log call svnfzf#hints#update('log')
    autocmd BufEnter svnfzf://preview call svnfzf#hints#update('preview')
    autocmd CursorMoved svnfzf://files call svnfzf#preview#on_cursor_moved('files')
    autocmd CursorMoved svnfzf://log call svnfzf#preview#on_cursor_moved('log')
  augroup END
endfunction

function! svnfzf#ui#close() abort
  if !s:is_open
    return
  endif

  augroup svnfzf_ui
    autocmd!
  augroup END

  for l:key in ['hints', 'log', 'preview', 'files']
    if has_key(s:bufnrs, l:key) && bufexists(s:bufnrs[l:key])
      execute 'bwipeout! ' . s:bufnrs[l:key]
    endif
  endfor

  let s:winids = {}
  let s:bufnrs = {}
  let s:is_open = 0

  if s:prev_winid > 0 && win_gotoid(s:prev_winid)
    " restored
  endif
endfunction

function! svnfzf#ui#get_bufnr(panel) abort
  return get(s:bufnrs, a:panel, -1)
endfunction

function! svnfzf#ui#get_winid(panel) abort
  return get(s:winids, a:panel, -1)
endfunction

function! svnfzf#ui#set_content(panel, lines) abort
  let l:bufnr = svnfzf#ui#get_bufnr(a:panel)
  if l:bufnr < 0
    return
  endif
  call setbufvar(l:bufnr, '&modifiable', 1)
  call deletebufline(l:bufnr, 1, '$')
  call setbufline(l:bufnr, 1, a:lines)
  call setbufvar(l:bufnr, '&modifiable', 0)
endfunction

function! svnfzf#ui#set_preview(lines, filetype) abort
  let l:bufnr = svnfzf#ui#get_bufnr('preview')
  if l:bufnr < 0
    return
  endif
  call setbufvar(l:bufnr, '&modifiable', 1)
  call deletebufline(l:bufnr, 1, '$')
  call setbufline(l:bufnr, 1, a:lines)
  call setbufvar(l:bufnr, '&modifiable', 0)
  call setbufvar(l:bufnr, '&filetype', a:filetype)
endfunction

function! s:setup_panel_buf(name) abort
  execute 'file ' . a:name
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  setlocal nonumber norelativenumber signcolumn=no foldcolumn=0
  setlocal nomodifiable
  setlocal cursorline
endfunction
