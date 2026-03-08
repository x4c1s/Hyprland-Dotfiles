set termguicolors
set laststatus=2

" 1. Load your existing tokyonight theme
let g:tokyonight_enable_italic = 1
let g:lightline = {'colorscheme' : 'tokyonight'}

" Try to load tokyonight; if it fails, it won't crash your vim
silent! colorscheme tokyonight

" 2. THE BLACKOUT OVERRIDE
" This removes the theme's background so it uses Ghostty's #000000
function! TransparencyOverride()
    highlight Normal     guibg=NONE ctermbg=NONE
    highlight NonText    guibg=NONE ctermbg=NONE
    highlight NormalNC   guibg=NONE ctermbg=NONE
    highlight SignColumn guibg=NONE ctermbg=NONE
    highlight EndOfBuffer guibg=NONE ctermbg=NONE
endfunction

" Apply the override immediately and whenever a colorscheme is loaded
autocmd ColorScheme * call TransparencyOverride()
call TransparencyOverride()
