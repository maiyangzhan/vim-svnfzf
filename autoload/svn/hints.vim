" autoload/svn/hints.vim — Hint bar

let s:hints_map = {
      \ 'files': 'd:diff  c:commit  r:revert  a:add  x:delete  m:resolve  SPACE:mark  R:refresh  u:update  q:quit',
      \ 'log': 'd:diff  ENTER:diff  R:refresh  q:quit',
      \ 'preview': 'q:quit',
      \ }

function! svn#hints#update(panel) abort
  let l:text = get(s:hints_map, a:panel, '')
  call svn#ui#set_content('hints', [' ' . l:text])
endfunction
