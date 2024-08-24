; https://github.com/ngalaiko/tree-sitter-go-template?tab=readme-ov-file#neovim-integration-using-nvim-treesitter
; https://github.com/ray-x/go.nvim/blob/master/queries/gotmpl/injections.scm

(text) @yaml

((text) @injection.content
 (#set! injection.language "html")
 (#set! injection.combined))

((text) @injection.content
 (#set! injection.language "javascript")
 (#set! injection.combined))
