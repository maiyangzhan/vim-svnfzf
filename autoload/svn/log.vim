" autoload/svn/log.vim — Log panel

function! svn#log#render() abort
  let l:limit = get(g:, 'svn_log_limit', 50)
  let l:raw = system('svn log --limit ' . l:limit . ' 2>/dev/null')
  let l:entries = svn#utils#parse_log(l:raw)
  let l:lines = svn#utils#format_log(l:entries)
  if empty(l:lines)
    let l:lines = ['  No log entries']
  endif
  call svn#ui#set_content('log', l:lines)
endfunction

function! svn#log#setup_keys() abort
  execute 'nnoremap <buffer> <silent> d :call svn#log#do_diff()<CR>'
  execute 'nnoremap <buffer> <silent> <CR> :call svn#log#do_diff()<CR>'
  execute 'nnoremap <buffer> <silent> R :call svn#log#render()<CR>'
  execute 'nnoremap <buffer> <silent> q :call svn#close()<CR>'
endfunction

function! svn#log#get_current_rev() abort
  let l:line = getline('.')
  return matchstr(l:line, '\[r\zs\d\+\ze\]')
endfunction

function! svn#log#do_diff() abort
  let l:rev = svn#log#get_current_rev()
  if empty(l:rev)
    return
  endif
  let l:output = svn#utils#run('svn diff -c ' . l:rev)
  if l:output !=# ''
    call svn#ui#set_preview(split(l:output, '\n'), 'diff')
  endif
endfunction
