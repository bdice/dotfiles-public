" Install Vundle with
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" Then run :PluginInstall

set nocompatible              " be iMproved, required
filetype off                  " required

" Set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" Alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Vundle plugins:
" General utilities:
Plugin 'vim-airline/vim-airline'         " Cute helpful status bar
"Plugin 'valloric/youcompleteme'         " Disabled, requires an extra compilation step
"Plugin 'ctrlpvim/ctrlp.vim'             " Disabled, magic stuff but it's sloooow
Plugin 'scrooloose/nerdtree'             " Directory navigation in sidebar
Plugin 'Xuyuanp/nerdtree-git-plugin'     " Show git status in NERDTree
Plugin 'tpope/vim-abolish'               " Case-matching replace with :%S/find/replace/g

" Whitespace management
Plugin 'ntpeters/vim-better-whitespace'  " Show and strip trailing whitespace
Plugin 'hynek/vim-python-pep8-indent'    " Use PEP8 indenting
Plugin 'raimondi/yaifa'                  " Determine indent settings automatically

" Syntax plugins:
Plugin 'vim-syntastic/syntastic'         " Syntax checking
Plugin 'tshirtman/vim-cython'            " Syntax highlighting for Cython
Plugin 'isRuslan/vim-es6'                " Syntax highlighting for ES6
Plugin 'glench/vim-jinja2-syntax'        " Syntax highlighting for jinja2
Plugin 'cakebaker/scss-syntax.vim'       " Syntax highlighting for SCSS
Plugin 'cespare/vim-toml'                " Syntax highlighting for TOML
Plugin 'leafgarland/typescript-vim'      " Syntax highlighting for TypeScript

" Web development plugins:
Plugin 'ap/vim-css-color'                " Color CSS colors with their actual color
Plugin 'alvan/vim-closetag'              " HTML auto-close tags

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Custom filetype extensions
au BufNewFile,BufRead *.cuh set filetype=cpp
au BufNewFile,BufRead *.pxd,*.pxi,*.pyx set filetype=python

" Disable Background Color Erase (BCE) so that color schemes
" work properly when Vim is used inside tmux and GNU screen.
if &term =~ '256color'
    set t_ut=
endif

" Tab completion improvements
set wildmenu
set wildmode=longest:full,full

" Persistent undo history across sessions, by storing in file.
if has('persistent_undo')
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

" Search options
set wrapscan  " Wrap back to top of document for search
set incsearch " Search as you type (incremental)

" Set tab and indent size to 4 real spaces
set tabstop=4
set shiftwidth=4
set expandtab

" Set soft tab settings so backspace intelligently deletes 4 spaces as if they were a tab
set softtabstop=4
set backspace=indent,eol,start

" ... except for web files where 2 spaces are preferred
autocmd FileType html,css,scss,javascript setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab

" Enable simple autoindenting
set autoindent

" Show tabs and line endings with <F8>
map <F8> :set list!<CR>
" Hide errors on systems that don't support these characters
try
    set listchars=tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨
catch
endtry

" Treat broken lines as multiple lines with j/k
map j gj
map k gk

" Keep selection when using indentation
vnoremap > >gv
vnoremap < <gv

" Options to make the UI more friendly
set ruler
syntax enable
set nobackup

" Set pane switching shortcuts
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
set splitbelow
set splitright

" Autoresize panes when vim is resized
autocmd VimResized * wincmd =

" Set buffer switching shortcuts
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>

" In insert and visual modes, tab and shift-tab indent lines.
inoremap <S-Tab> <C-D>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" Enable mouse
set mouse=a

" Filetype settings
autocmd FileType c,cpp,cu,h,hpp,cuh set colorcolumn=80
autocmd FileType python set colorcolumn=80
autocmd FileType javascript set syntax=javascript

" Easy run with F5
autocmd FileType python nnoremap <buffer> <F5> :exec '!clear;python' shellescape(@%, 1)<CR>
autocmd FileType sh nnoremap <buffer> <F5> :exec '!clear;bash' shellescape(@%, 1)<CR>

" Toggle paste mode with F6
set pastetoggle=<F6>

" Reformat all indentation with F7
" Set to Whitesmith style with Ctrl-F7, reset to default with Ctrl-Shift-F7
set cinoptions&
map <F7> mzgg=G`z
map <C-F7> :set cinoptions={1s,f1s<CR>
map <C-S-F7> :set cinoptions&<CR>

" Highlight unwanted spaces/tags in red
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$\|\t/

" Monokai color scheme
syntax on
colorscheme monokai
set t_Co=256  " vim-monokai now only support 256 colours in terminal.
let g:monokai_term_italic = 1
let g:monokai_gui_italic = 1

" NERDTree toggle
map <F2> :NERDTreeToggle<CR>

" Launch NERDTree if no command line arguments are given to vim
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Keep NERDTree open when opening a file
let NERDTreeQuitOnOpen = 0

" Airline settings
set laststatus=2 " Needed for Airline without splits
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" Syntastic settings
let g:syntastic_mode_map = { 'passive_filetypes': ['python'] }

" YouCompleteMe settings
"let g:ycm_autoclose_preview_window_after_insertion = 1
"let g:ycm_autoclose_preview_window_after_completion = 1
"let g:ycm_auto_trigger = 0

" Trim trailing whitespace on save (vim-better-whitespace)
autocmd BufEnter * EnableStripWhitespaceOnSave

" Autoclose HTML tags for filenames like *.xml, *.html, *.xhtml, ...
let g:closetag_filenames = "*.xml,*.html,*.xhtml,*.phtml,*.php"

" For use in syntax highlighting - press F10 to see the current match
" map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
" \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
" \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
