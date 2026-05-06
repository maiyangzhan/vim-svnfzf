" autoload/svnfzf.vim — Entry point

function! svnfzf#open() abort
  if !svnfzf#utils#is_svn_repo()
    echohl ErrorMsg
    echom 'Not in a SVN working copy'
    echohl None
    return
  endif

  call svnfzf#ui#open()

  call svnfzf#files#render()
  call svnfzf#files#setup_keys()

  let l:log_winid = svnfzf#ui#get_winid('log')
  if l:log_winid > 0
    call win_gotoid(l:log_winid)
    call svnfzf#log#render()
    call svnfzf#log#setup_keys()
  endif

  let l:preview_winid = svnfzf#ui#get_winid('preview')
  if l:preview_winid > 0
    call win_gotoid(l:preview_winid)
    call svnfzf#preview#setup_keys()
  endif

  let l:files_winid = svnfzf#ui#get_winid('files')
  if l:files_winid > 0
    call win_gotoid(l:files_winid)
  endif

  call svnfzf#hints#update('files')
endfunction

function! svnfzf#close() abort
  call svnfzf#ui#close()
endfunction
