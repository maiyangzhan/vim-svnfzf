" autoload/svn/utils.vim

function! svn#utils#is_svn_repo() abort
  let l:output = system('svn info 2>&1')
  return v:shell_error == 0
endfunction

function! svn#utils#run(cmd) abort
  let l:output = system(a:cmd)
  if v:shell_error != 0
    echohl ErrorMsg
    echom '[svn] ' . substitute(l:output, '\n$', '', '')
    echohl None
    return ''
  endif
  return l:output
endfunction

function! svn#utils#parse_status(raw) abort
  let l:entries = []
  for l:line in split(a:raw, '\n')
    let l:match = matchlist(l:line, '^\(.\)\s\+\(.\+\)$')
    if !empty(l:match)
      call add(l:entries, {'status': l:match[1], 'file': l:match[2]})
    endif
  endfor
  return l:entries
endfunction

function! svn#utils#group_status(entries) abort
  let l:groups = {'M': [], 'A': [], 'D': [], '?': [], 'C': []}
  let l:labels = {'M': 'Modified', 'A': 'Added', 'D': 'Deleted', '?': 'Untracked', 'C': 'Conflicted'}
  let l:order = ['M', 'A', 'D', '?', 'C']
  for l:e in a:entries
    let l:key = l:e.status
    if has_key(l:groups, l:key)
      call add(l:groups[l:key], l:e)
    endif
  endfor
  let l:lines = []
  for l:s in l:order
    if !empty(l:groups[l:s])
      call add(l:lines, '-- ' . l:labels[l:s] . ' ' . repeat('-', 30))
      for l:e in l:groups[l:s]
        call add(l:lines, '[' . l:e.status . ']  ' . l:e.file)
      endfor
    endif
  endfor
  return l:lines
endfunction

function! svn#utils#svn_wc_prefix() abort
  let l:info = system('svn info 2>/dev/null')
  let l:url = matchstr(l:info, 'URL: \zs[^\n]\+')
  let l:root = matchstr(l:info, 'Repository Root: \zs[^\n]\+')
  if empty(l:url) || empty(l:root)
    return ''
  endif
  return strpart(l:url, len(l:root))
endfunction

function! svn#utils#parse_log(raw) abort
  let l:entries = []
  let l:blocks = split(a:raw, '-\{72\}')
  for l:block in l:blocks
    let l:lines = split(l:block, '\n')
    if len(l:lines) < 2
      continue
    endif
    let l:meta = matchlist(l:lines[0], '^r\(\d\+\)\s*|\s*\(\S\+\)\s*|\s*\(\d\{4\}-\d\{2\}-\d\{2\}\)..\+')
    if empty(l:meta)
      continue
    endif
    let l:msg = join(l:lines[1:], ' ')
    let l:msg = substitute(l:msg, '^\s\+\|\s\+$', '', 'g')
    call add(l:entries, {
          \ 'rev': l:meta[1],
          \ 'author': l:meta[2],
          \ 'date': l:meta[3],
          \ 'msg': l:msg
          \ })
  endfor
  return l:entries
endfunction

function! svn#utils#format_log(entries) abort
  let l:lines = []
  for l:e in a:entries
    let l:line = printf('[r%s]  %s  %-12s|  %s', l:e.rev, l:e.date, l:e.author, l:e.msg)
    call add(l:lines, l:line)
  endfor
  return l:lines
endfunction
