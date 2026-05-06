" autoload/svn/preview.vim — Preview panel auto-update

let s:last_preview = ''

function! svn#preview#on_cursor_moved(panel) abort
  if a:panel ==# 'files'
    call s:preview_file()
  elseif a:panel ==# 'log'
    call s:preview_log()
  endif
endfunction

function! svn#preview#setup_keys() abort
  execute 'nnoremap <buffer> <silent> q :call svn#close()<CR>'
endfunction

function! s:preview_file() abort
  let l:line = getline('.')
  if l:line =~# '^--' || l:line =~# '^\s*$' || l:line =~# 'Working copy is clean'
    return
  endif
  let l:status = matchstr(l:line, '\[\zs.\ze\]')
  let l:file = matchstr(l:line, '\[.\]\s\+\zs.\+$')
  if empty(l:file)
    return
  endif

  let l:key = l:status . ':' . l:file
  if l:key ==# s:last_preview
    return
  endif
  let s:last_preview = l:key

  if l:status ==# 'M' || l:status ==# 'C'
    let l:output = system('svn diff ' . shellescape(l:file) . ' 2>/dev/null')
    call svn#ui#set_preview(split(l:output, '\n'), 'diff')
  elseif l:status ==# 'D'
    call svn#ui#set_preview(['File marked for deletion'], 'text')
  else
    let l:output = system('head -200 ' . shellescape(l:file) . ' 2>/dev/null')
    if empty(l:output)
      call svn#ui#set_preview(['(empty file)'], 'text')
    else
      let l:ft = matchstr(l:file, '\.\zs[^.]*$')
      let l:ftype = l:ft ==# 'sv' || l:ft ==# 'svh' ? 'systemverilog'
            \ : l:ft ==# 'v' ? 'verilog' : 'text'
      call svn#ui#set_preview(split(l:output, '\n'), l:ftype)
    endif
  endif
endfunction

function! s:preview_log() abort
  let l:rev = svn#log#get_current_rev()
  if empty(l:rev)
    return
  endif

  let l:key = 'log:' . l:rev
  if l:key ==# s:last_preview
    return
  endif
  let s:last_preview = l:key

  let l:output = system('svn log -v -r ' . l:rev . ' 2>/dev/null')
  call svn#ui#set_preview(split(l:output, '\n'), 'text')
endfunction
