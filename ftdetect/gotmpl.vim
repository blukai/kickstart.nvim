" NOTE(blukai): stuff down below seems broken
"
" https://github.com/ngalaiko/tree-sitter-go-template?tab=readme-ov-file#neovim-integration-using-nvim-treesitter
" https://github.com/ray-x/go.nvim/blob/78c6d7b970a79c34dc0f35149f4bd845e09803d6/ftdetect/filetype.vim#L7C1-L8C55
" autocmd BufNewFile,BufRead * if search('{{.\+}}', 'nw') | setlocal filetype=gotmpl | endif

" https://github.com/ray-x/go.nvim/blob/78c6d7b970a79c34dc0f35149f4bd845e09803d6/ftdetect/filetype.vim

let s:cpo_save = &cpo
set cpo&vim

au BufRead,BufNewFile *.go setfiletype go
au BufRead,BufNewFile *.s setfiletype asm
au BufRead,BufNewFile *.tmpl set filetype=gotexttmpl
au BufRead,BufNewFile *.gotext set filetype=gotexttmpl
au BufRead,BufNewFile *.gohtml set filetype=gohtmltmpl
au BufRead,BufNewFile go.sum set filetype=gosum
au BufRead,BufNewFile go.work.sum set filetype=gosum
au BufRead,BufNewFile go.work set filetype=gowork

au! BufRead,BufNewFile *.mod,*.MOD
au BufRead,BufNewFile *.mod,*.MOD set filetype=gomod


let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
