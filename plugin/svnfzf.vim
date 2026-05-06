" plugin/svnfzf.vim

if exists('g:loaded_svnfzf')
  finish
endif
let g:loaded_svnfzf = 1

let g:svnfzf_map = get(g:, 'svnfzf_map', '<Leader>s')
let g:svnfzf_log_limit = get(g:, 'svnfzf_log_limit', 50)
let g:svnfzf_diff_highlight = get(g:, 'svnfzf_diff_highlight', 1)

command! -nargs=0 SvnFzf call svnfzf#open()

execute 'nnoremap <silent> ' . g:svnfzf_map . ' :SvnFzf<CR>'
