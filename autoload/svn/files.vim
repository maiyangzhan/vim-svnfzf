" autoload/svn/files.vim — Files panel

let s:marked = {}
let s:entries = []

function! svn#files#render() abort
  let l:raw = system('svn status 2>/dev/null')
  let s:entries = svn#utils#parse_status(l:raw)
  let s:marked = {}
  call s:render_lines()
endfunction

function! svn#files#setup_keys() abort
  let l:bufnr = svn#ui#get_bufnr('files')
  if l:bufnr < 0
    return
  endif

  execute 'nnoremap <buffer> <silent> <Space> :call svn#files#toggle_mark()<CR>'
  execute 'nnoremap <buffer> <silent> d :call svn#files#do_diff()<CR>'
  execute 'nnoremap <buffer> <silent> c :call svn#files#do_commit()<CR>'
  execute 'nnoremap <buffer> <silent> r :call svn#files#do_revert()<CR>'
  execute 'nnoremap <buffer> <silent> a :call svn#files#do_add()<CR>'
  execute 'nnoremap <buffer> <silent> x :call svn#files#do_delete()<CR>'
  execute 'nnoremap <buffer> <silent> m :call svn#files#do_resolve()<CR>'
  execute 'nnoremap <buffer> <silent> R :call svn#files#render()<CR>'
  execute 'nnoremap <buffer> <silent> u :call svn#files#do_update()<CR>'
  execute 'nnoremap <buffer> <silent> q :call svn#close()<CR>'
endfunction

function! svn#files#get_current() abort
  let l:line = getline('.')
  if l:line =~# '^\*\?\s*\[.\]'
    let l:status = matchstr(l:line, '\[\zs.\ze\]')
    let l:file = matchstr(l:line, '\[.\]\s\+\zs.\+$')
    return {'status': l:status, 'file': l:file}
  endif
  return {}
endfunction

function! svn#files#get_targets() abort
  if !empty(s:marked)
    return values(s:marked)
  endif
  let l:cur = svn#files#get_current()
  if !empty(l:cur)
    return [l:cur]
  endif
  return []
endfunction

function! svn#files#toggle_mark() abort
  let l:cur = svn#files#get_current()
  if empty(l:cur)
    return
  endif
  if has_key(s:marked, l:cur.file)
    call remove(s:marked, l:cur.file)
  else
    let s:marked[l:cur.file] = l:cur
  endif
  call s:render_lines()
  normal! j
endfunction

function! svn#files#do_diff() abort
  let l:targets = svn#files#get_targets()
  if empty(l:targets)
    return
  endif
  let l:paths = map(copy(l:targets), 'v:val.file')
  let l:cmd = 'svn diff ' . join(map(copy(l:paths), 'shellescape(v:val)'), ' ')
  let l:output = svn#utils#run(l:cmd)
  if l:output !=# ''
    call svn#ui#set_preview(split(l:output, '\n'), 'diff')
  endif
endfunction

function! svn#files#do_commit() abort
  let l:targets = svn#files#get_targets()
  if empty(l:targets)
    return
  endif
  let l:paths = map(copy(l:targets), 'v:val.file')
  let l:msg = input('Commit message: ')
  if empty(l:msg)
    redraw
    echom 'Commit aborted: empty message'
    return
  endif
  let l:cmd = 'svn commit -m ' . shellescape(l:msg) . ' '
        \ . join(map(copy(l:paths), 'shellescape(v:val)'), ' ')
  let l:output = system(l:cmd)
  redraw
  if v:shell_error != 0
    echohl ErrorMsg | echom '[svn] ' . substitute(l:output, '\n$', '', '') | echohl None
  else
    echom substitute(l:output, '\n$', '', '')
    let s:marked = {}
    call svn#files#render()
  endif
endfunction

function! svn#files#do_revert() abort
  let l:targets = svn#files#get_targets()
  if empty(l:targets)
    return
  endif
  let l:paths = map(copy(l:targets), 'v:val.file')
  let l:confirm = input('Revert ' . len(l:paths) . ' file(s)? (y/n): ')
  if l:confirm !=? 'y'
    redraw | echom 'Revert cancelled'
    return
  endif
  let l:cmd = 'svn revert ' . join(map(copy(l:paths), 'shellescape(v:val)'), ' ')
  call svn#utils#run(l:cmd)
  redraw
  let s:marked = {}
  call svn#files#render()
endfunction

function! svn#files#do_add() abort
  let l:targets = svn#files#get_targets()
  if empty(l:targets)
    return
  endif
  let l:paths = map(copy(l:targets), 'v:val.file')
  let l:cmd = 'svn add ' . join(map(copy(l:paths), 'shellescape(v:val)'), ' ')
  call svn#utils#run(l:cmd)
  redraw
  let s:marked = {}
  call svn#files#render()
endfunction

function! svn#files#do_delete() abort
  let l:targets = svn#files#get_targets()
  if empty(l:targets)
    return
  endif
  let l:paths = map(copy(l:targets), 'v:val.file')
  let l:confirm = input('Delete ' . len(l:paths) . ' file(s)? (y/n): ')
  if l:confirm !=? 'y'
    redraw | echom 'Delete cancelled'
    return
  endif
  for l:f in l:paths
    call delete(l:f)
  endfor
  redraw
  let s:marked = {}
  call svn#files#render()
endfunction

function! svn#files#do_resolve() abort
  let l:targets = svn#files#get_targets()
  if empty(l:targets)
    return
  endif
  let l:paths = map(copy(l:targets), 'v:val.file')
  let l:cmd = 'svn resolve --accept working '
        \ . join(map(copy(l:paths), 'shellescape(v:val)'), ' ')
  call svn#utils#run(l:cmd)
  redraw
  let s:marked = {}
  call svn#files#render()
endfunction

function! svn#files#do_update() abort
  let l:output = system('svn update')
  call svn#ui#set_preview(split(l:output, '\n'), 'text')
  if l:output =~# '\(^\|\n\)C '
    echohl WarningMsg | echom 'Conflicts detected' | echohl None
  endif
  call svn#files#render()
endfunction

function! s:render_lines() abort
  let l:grouped = svn#utils#group_status(s:entries)
  let l:lines = []
  for l:line in l:grouped
    if l:line =~# '^--'
      call add(l:lines, l:line)
    else
      let l:file = matchstr(l:line, '\[.\]\s\+\zs.\+$')
      let l:prefix = has_key(s:marked, l:file) ? '* ' : '  '
      call add(l:lines, l:prefix . l:line)
    endif
  endfor
  if empty(l:lines)
    let l:lines = ['  Working copy is clean']
  endif
  call svn#ui#set_content('files', l:lines)
endfunction
