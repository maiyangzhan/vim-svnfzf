" plugin/svn.vim

if exists('g:loaded_svn')
  finish
endif
let g:loaded_svn = 1

let g:svn_map = get(g:, 'svn_map', '<Leader>s')
let g:svn_log_limit = get(g:, 'svn_log_limit', 50)
let g:svn_diff_highlight = get(g:, 'svn_diff_highlight', 1)

command! -nargs=0 Svn call svn#open()

execute 'nnoremap <silent> ' . g:svn_map . ' :Svn<CR>'
