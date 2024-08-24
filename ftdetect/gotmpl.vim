" https://github.com/ngalaiko/tree-sitter-go-template?tab=readme-ov-file#neovim-integration-using-nvim-treesitter
" https://github.com/ray-x/go.nvim/blob/78c6d7b970a79c34dc0f35149f4bd845e09803d6/ftdetect/filetype.vim#L7C1-L8C55
autocmd BufNewFile,BufRead * if search('{{.\+}}', 'nw') | setlocal filetype=gotmpl | endif
