" autoload/svnfzf/log.vim — Log panel

function! svnfzf#log#render() abort
  let l:limit = get(g:, 'svnfzf_log_limit', 50)
  let l:raw = system('svn log --limit ' . l:limit . ' 2>/dev/null')
  let l:entries = svnfzf#utils#parse_log(l:raw)
  let l:lines = svnfzf#utils#format_log(l:entries)
  if empty(l:lines)
    let l:lines = ['  No log entries']
  endif
  call svnfzf#ui#set_content('log', l:lines)
endfunction

function! svnfzf#log#setup_keys() abort
  execute 'nnoremap <buffer> <silent> d :call svnfzf#log#do_diff()<CR>'
  execute 'nnoremap <buffer> <silent> <CR> :call svnfzf#log#do_diff()<CR>'
  execute 'nnoremap <buffer> <silent> R :call svnfzf#log#render()<CR>'
  execute 'nnoremap <buffer> <silent> q :call svnfzf#close()<CR>'
endfunction

function! svnfzf#log#get_current_rev() abort
  let l:line = getline('.')
  return matchstr(l:line, '\[r\zs\d\+\ze\]')
endfunction

function! svnfzf#log#do_diff() abort
  let l:rev = svnfzf#log#get_current_rev()
  if empty(l:rev)
    return
  endif
  let l:output = svnfzf#utils#run('svn diff -c ' . l:rev)
  if l:output !=# ''
    call svnfzf#ui#set_preview(split(l:output, '\n'), 'diff')
  endif
endfunction
