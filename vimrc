" https://slides.tonycrane.cc/PracticalSkillsTutorial/lec1/#/3/6
syntax on
set expandtab
set number
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set softtabstop=4
set laststatus=2
set mouse=a
set scrolloff=4
inoremap { {}<ESC>i
inoremap {<CR> {<CR>}<ESC>O

" https://stackoverflow.com/a/38258720/17347885
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"
inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()
function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction
