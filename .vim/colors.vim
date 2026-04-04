set termguicolors
set laststatus=2

" 1. Gruvbox Material Configuration
let g:gruvbox_material_background = 'hard'
let g:gruvbox_material_enable_italic = 1
let g:gruvbox_material_better_performance = 1

" Match the lightline theme to Gruvbox
let g:lightline = {'colorscheme' : 'gruvbox_material'}

" Load the colorscheme
silent! colorscheme gruvbox-material

" 2. THE TRANSPARENCY OVERRIDE
" This ensures Vim doesn't paint a solid box over your wallpaper
function! TransparencyOverride()
    highlight Normal       guibg=NONE ctermbg=NONE
    highlight NonText      guibg=NONE ctermbg=NONE
    highlight NormalNC     guibg=NONE ctermbg=NONE
    highlight SignColumn   guibg=NONE ctermbg=NONE
    highlight EndOfBuffer  guibg=NONE ctermbg=NONE
    " Also clear the line numbers and fold columns for a cleaner look
    highlight LineNr       guibg=NONE ctermbg=NONE
    highlight CursorLineNr guibg=NONE ctermbg=NONE
    highlight FoldColumn   guibg=NONE ctermbg=NONE
endfunction

" Apply the override
autocmd ColorScheme * call TransparencyOverride()
call TransparencyOverride()
