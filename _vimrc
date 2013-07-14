set nocompatible

call pathogen#infect()
call pathogen#helptags()

syntax on
" Load SCSS syntax
au BufRead,BufNewFile *.scss set filetype=scss

filetype on
filetype indent on
filetype plugin on

set background=light
set lines=45
colo desert " colorscheme

" ==================================================
" SCRATCH BUFFER STUFF
" ==================================================

function! NewScratch()
    if ( !bufexists('[Scratch]') )  
        "create a new scratch buffer
        new [Scratch]
        setlocal buftype=nofile bufhidden=hide switchbuf=useopen noswapfile nowrap
    else  
        "open the existing scratch buffer
        sb \[Scratch]
    endif
endfunction

" CTRL-SHIFT-S runs NewScratch()
nmap <C-S-s> :call NewScratch()<CR>

" ==================================================
" END OF SCRATCH BUFFER STUFF
" ==================================================

" ==================================================
" STATUSLINE STUFF (must go below colorscheme!)
" ==================================================

set laststatus=2        " always have a status line
set statusline=         " start with a fresh statusline (for reloads)
set statusline=\ %2*%F\ %3*%m%r%h%w%=%1*[\ %2*FORMAT=%{&ff}\ %1*][\ %2*TYPE=%Y\ %1*][\ %2*line\ %02l\ (%p%%)\ %1*]\ 

" Mode Indication 
function! InsertStatuslineColor(mode)
  hi statusline ctermbg=1 guibg=#BF9B6E guibg=#83BFB4
  hi User1 ctermbg=1 ctermfg=15 guibg=#83BFB4 guifg=#53897D
  hi User2 ctermbg=1 ctermfg=15 guibg=#83BFB4
  hi User3 ctermbg=1 ctermfg=15 guibg=#83BFB4 guifg=#990000
endfunction

function! InsertLeaveActions()
  hi statusline ctermbg=7 guibg=#BF9B6E
  hi User1 ctermbg=7 ctermfg=0 guibg=#BF9B6E guifg=#9B7D5A
  hi User2 ctermbg=7 ctermfg=0 guibg=#BF9B6E
  hi User3 ctermbg=7 ctermfg=1 guibg=#BF9B6E
endfunction

" statusline color schemes
hi statusline ctermbg=7 guibg=#BF9B6E
hi User1 ctermbg=7 ctermfg=0 guibg=#BF9B6E guifg=#9B7D5A
hi User2 ctermbg=7 ctermfg=0 guibg=#BF9B6E guifg=#FFFCDF
hi User3 ctermbg=7 ctermfg=1 guibg=#BF9B6E guifg=#990000

au InsertEnter * call InsertStatuslineColor(v:insertmode)
au InsertLeave * call InsertLeaveActions()

" to handle exiting insert mode via a control-C
inoremap <c-c> <c-o>:call InsertLeaveActions()<cr><c-c>

" ==================================================
" END OF STATUSLINE STUFF
" ==================================================

" au BufWinLeave * mkview
" au BufWinEnter * silent loadview

set tw=74			" wrap text at the 74th column
set si				" sticky autoindent
set ts=2			" set tabstops at 2
set expandtab		" use spaces instead of tabs
set sw=4
set bs=2			" allow backspacing over everything in insert mode
set showmatch		" jump emacs style to matching bracket
set incsearch		" highlight match while typing search pattern
set hlsearch
" set ai			" always set autoindenting on
" set backup		" keep a backup file
set viminfo='20,\"50	" read/write a .viminfo file, don't store more
					" than 50 lines of registers
set history=50		" keep 50 lines of command line history
set ruler			" show the cursor position all the time
set mouse=a			" use a mouse
set encoding=utf-8
set autoread<

" Auto-run NERDtree
autocmd VimEnter * exe 'NERDTree'

" Map CTRL-\ to toggle NERDTree
nmap <C-BSlash> :NERDTreeToggle \| :silent NERDTreeMirror<CR>

" OS specific stuff, like fonts? Sure.
if has('mac')
    " Open current buffer in a web browser
    " Key command: 'CMD+1 s' for Safari, 'CMD+1 f' for Firefox
    noremap <silent> <D-1>f :exe ':silent !open -a /Applications/Firefox.app %'<CR>"
    noremap <silent> <D-1>s :exe ':silent !open -a /Applications/Safari.app %'<CR>"
elseif has('win32')
    " For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
    " let &guioptions = substitute(&guioptions, "t", "", "g")
    "set guifont=-dec-terminal-medium-r-normal-*-*-140-*-*-c-*-iso8859-1
    "set guifont=-schumacher-clean-medium-r-normal-*-*-130-*-*-c-*-iso646.1991-irv
else
    " do Linux stuff, I guess
endif

" Don't use Ex mode, use Q for formatting
map Q gq

" Make p in Visual mode replace the selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

" Only do this part when compiled with support for autocommands.
if has("autocmd")

 " In text files, always limit the width of text to 78 characters
 autocmd BufRead *.txt set tw=78

 augroup cprog
  " Remove all cprog autocommands
  au!

  " When starting to edit a file:
  "   For C and C++ files set formatting of comments and set C-indenting on.
  "   For other files switch it off.
  "   Don't change the order, it's important that the line with * comes first.
  autocmd FileType *      set formatoptions=tcql nocindent comments&
  autocmd FileType c,cpp  set formatoptions=croql cindent comments=sr:/*,mb:*,el:*/,://
 augroup END

 augroup gzip
  " Remove all gzip autocommands
  au!

  " Enable editing of gzipped files
  " set binary mode before reading the file
  autocmd BufReadPre,FileReadPre	*.gz,*.bz2 set bin
  autocmd BufReadPost,FileReadPost	*.gz call GZIP_read("gunzip")
  autocmd BufReadPost,FileReadPost	*.bz2 call GZIP_read("bunzip2")
  autocmd BufWritePost,FileWritePost	*.gz call GZIP_write("gzip")
  autocmd BufWritePost,FileWritePost	*.bz2 call GZIP_write("bzip2")
  autocmd FileAppendPre			*.gz call GZIP_appre("gunzip")
  autocmd FileAppendPre			*.bz2 call GZIP_appre("bunzip2")
  autocmd FileAppendPost		*.gz call GZIP_write("gzip")
  autocmd FileAppendPost		*.bz2 call GZIP_write("bzip2")

  " After reading compressed file: Uncompress text in buffer with "cmd"
  fun! GZIP_read(cmd)
    " set 'cmdheight' to two, to avoid the hit-return prompt
    let ch_save = &ch
    set ch=3
    " when filtering the whole buffer, it will become empty
    let empty = line("'[") == 1 && line("']") == line("$")
    let tmp = tempname()
    let tmpe = tmp . "." . expand("<afile>:e")
    " write the just read lines to a temp file "'[,']w tmp.gz"
    execute "'[,']w " . tmpe
    " uncompress the temp file "!gunzip tmp.gz"
    execute "!" . a:cmd . " " . tmpe
    " delete the compressed lines
    '[,']d
    " read in the uncompressed lines "'[-1r tmp"
    set nobin
    execute "'[-1r " . tmp
    " if buffer became empty, delete trailing blank line
    if empty
      normal Gdd''
    endif
    " delete the temp file
    call delete(tmp)
    let &ch = ch_save
    " When uncompressed the whole buffer, do autocommands
    if empty
      execute ":doautocmd BufReadPost " . expand("%:r")
    endif
  endfun

  " After writing compressed file: Compress written file with "cmd"
  fun! GZIP_write(cmd)
    if rename(expand("<afile>"), expand("<afile>:r")) == 0
      execute "!" . a:cmd . " <afile>:r"
    endif
  endfun

  " Before appending to compressed file: Uncompress file with "cmd"
  fun! GZIP_appre(cmd)
    execute "!" . a:cmd . " <afile>"
    call rename(expand("<afile>:r"), expand("<afile>"))
  endfun

 augroup END

 " This is disabled, because it changes the jumplist.  Can't use CTRL-O to go
 " back to positions in previous files more than once.
 if 0
  " When editing a file, always jump to the last cursor position.
  " This must be after the uncompress commands.
   autocmd BufReadPost * if line("'\"") && line("'\"") <= line("$") | exe "normal `\"" | endif
 endif

endif " has("autocmd")
if &term =~ "xterm.*"
  " Tastatur-Belegung fuer diverse  vi's
  " Autor: Werner Fink   <werner@suse.de> 
  " Version: 20.05.1997

  " keys in display mode
  map OA  k
  map [A  k
  map OB  j
  map [B  j
  map OD  h
  map [D  h
  map     h
  map     h
  map OC  l
  map [C  l
  map [2~ i
  map [3~ x
  map [1~ 0
  map OH  0
  map [H  0
  map [4~ $
  map OF  $
  map [F  $
  map [5~ 
  map [6~ 
  map [E  ""
  map [G  ""
  map OE  ""
  map Oo  :
  map Oj  *
  map Om  -
  map Ok  +
  map Ol  +
  map OM  
  map Ow  7
  map Ox  8
  map Oy  9
  map Ot  4
  map Ou  5
  map Ov  6
  map Oq  1
  map Or  2
  map Os  3
  map Op  0
  map On  .

  " keys in insert mode
  map! Oo  :
  map! Oj  *
  map! Om  -
  map! Ok  +
  map! Ol  +
  map! OM  
  map! Ow  7
  map! Ox  8
  map! Oy  9
  map! Ot  4
  map! Ou  5
  map! Ov  6
  map! Oq  1
  map! Or  2
  map! Os  3
  map! Op  0
  map! On  .

endif

" Folded text stuff
highlight Folded ctermbg=darkcyan ctermfg=white
highlight FoldColumn ctermbg=grey ctermfg=darkcyan
set foldcolumn=2

" Save and restore all views (including folds!) for .c and .h files
au BufWinLeave *.c mkview
au BufWinEnter *.c silent loadview
au BufWinLeave *.cpp mkview
au BufWinEnter *.cpp silent loadview
au BufWinLeave *.h mkview
au BufWinEnter *.hpp silent loadview
au BufWinLeave *.hpp mkview
au BufWinEnter *.h silent loadview
