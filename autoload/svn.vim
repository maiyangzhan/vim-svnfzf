" autoload/svn.vim — Entry point

function! svn#open() abort
  if !svn#utils#is_svn_repo()
    echohl ErrorMsg
    echom 'Not in a SVN working copy'
    echohl None
    return
  endif

  call svn#ui#open()

  call svn#files#render()
  call svn#files#setup_keys()

  let l:log_winid = svn#ui#get_winid('log')
  if l:log_winid > 0
    call win_gotoid(l:log_winid)
    call svn#log#render()
    call svn#log#setup_keys()
  endif

  let l:preview_winid = svn#ui#get_winid('preview')
  if l:preview_winid > 0
    call win_gotoid(l:preview_winid)
    call svn#preview#setup_keys()
  endif

  let l:files_winid = svn#ui#get_winid('files')
  if l:files_winid > 0
    call win_gotoid(l:files_winid)
  endif

  call svn#hints#update('files')
endfunction

function! svn#close() abort
  call svn#ui#close()
endfunction
