" Setup & neobundle {{{
  set nocompatible
  set all& "reset everything to their defaults
  set runtimepath+=~/.vim/bundle/neobundle.vim/
  call neobundle#rc(expand('~/.vim/bundle/'))
  NeoBundleFetch 'Shougo/neobundle.vim'
"}}}

let s:cache_dir = '~/.vim/.cache'
function! s:get_cache_dir(suffix) "{{{
  return resolve(expand(s:cache_dir . '/' . a:suffix))
endfunction "}}}

" Source the vimrc file after saving it
if has("autocmd")
  autocmd bufwritepost .vimrc source $HOME/.vimrc
endif

" number of colors in terminal
set t_Co=256

set number
set relativenumber

set foldmethod=marker

set spell
set spelllang=en_us

" Allow backspacing everything in insert mode
set backspace=indent,eol,start

" Tabs and indent
set autoindent
set smartindent
set shiftwidth=4
set tabstop=4
set expandtab

set nowrap
set hlsearch
set hidden

set list
set listchars=tab:·\ ,trail:·,extends:»,precedes:«

set fillchars=stl:\ ,stlnc:\ ,vert:│

" Add extra characters that are valid parts of variables
set iskeyword+=$,@

" Disable swap and backup files
set noswapfile
set nobackup
set nowritebackup

" When the page starts to scroll, keep the cursor 8 lines from the top and 8
" lines from the bottom
set scrolloff=8

" Automatically read a file that has changed on disk
set autoread

" Allow buffer switching without saving
set hidden

set laststatus=2
set noruler

set background=dark

if exists('+colorcolumn')
  set colorcolumn=80
  autocmd WinLeave * setlocal nocursorcolumn
  autocmd WinEnter * setlocal cursorcolumn
endif

if has('gui_running') " {{{
  set cursorline
  autocmd WinLeave * setlocal nocursorline
  autocmd WinEnter * setlocal cursorline
  set guifont=Anonymous\ Pro\ for\ Powerline\ 11
  set guioptions=
  set mouse=
endif
"}}}

" NeoBundle begin {{{

" Core {{{
  " Extends the existing functionality of '%' key
  NeoBundle 'matchit.zip'
  NeoBundle 'tpope/vim-surround'

  " The ultimate vim statusline utility
  NeoBundle 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}

  " A tree explorer plugin for vim
  NeoBundleLazy 'scrooloose/nerdtree', {'autoload':{'commands':['NERDTreeToggle','NERDTreeFind']}} "{{{
    let NERDTreeShowHidden=1
    let NERDTreeQuitOnOpen=0
    let NERDTreeChDirMode=0
    let NERDTreeShowBookmarks=1
    let NERDTreeIgnore=['\.git']
    let NERDTreeBookmarksFile=s:get_cache_dir('NERDTreeBookmarks')
    nmap <silent> <A-f> :NERDTreeFind<CR>
  "}}}

  NeoBundle 'Shougo/vimproc.vim', {'build': {'unix': 'make -f make_unix.mak'}}
" }}}

" Unite {{{

  " Unite and create user interfaces
  NeoBundle 'Shougo/unite.vim' "{{{
    let g:unite_data_directory=s:get_cache_dir('unite')
    let g:unite_enable_start_insert=1
    let g:unite_source_history_yank_enable=1
    let g:unite_source_rec_max_cache_files=5000
    let g:unite_prompt='» '

  if executable('ack')
    let g:unite_source_grep_command='ack'
    let g:unite_source_grep_default_opts='--no-heading --no-color -C4'
    let g:unite_source_grep_recursive_opt=''
  endif

    nmap <space> [unite]
    nnoremap [unite] <nop>

    nnoremap <silent> [unite]f :<C-u>Unite -toggle -auto-resize -buffer-name=files file_rec/async:!<cr><c-u>
    nnoremap <silent> [unite]y :<C-u>Unite -buffer-name=yanks history/yank<cr>
    nnoremap <silent> [unite]/ :<C-u>Unite -no-quit -buffer-name=search grep:.<cr>
    nnoremap <silent> [unite]s :<C-u>Unite -toggle -auto-resize -quick-match buffer<cr>
  "}}}
"}}}

" Autocomplete {{{
  NeoBundle 'Shougo/neocomplete.vim' "{{{
    let g:neocomplete#enable_at_startup = 1
    let g:neocomplete#enable_smart_case = 1
    let g:neocomplete#sources#syntax#min_keyword_length = 3
    let g:neocomplete#data_directory=s:get_cache_dir('neocomplete')

    " Recommended key-mappings.
    " <CR>: close popup and save indent.
    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    function! s:my_cr_function()
      return pumvisible() ? neocomplete#close_popup() : "\<CR>"
    endfunction
    " <BS>: close popup and delete backword char.
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
  "}}}
" }}}

" PHP {{{

  " PHP Documentor for VIM - Generates PHP docblocks
  NeoBundleLazy 'tobyS/pdv', {'depends': 'tobyS/vmustache', 'autoload': {'filetypes': 'php'}} "{{{
    let g:pdv_template_dir = $HOME."/.vim/bundle/pdv/templates_snip"
    nnoremap <leader><leader>p :call pdv#DocumentWithSnip()<CR>
  "}}}
"}}}

" Snippets {{{
  NeoBundle 'honza/vim-snippets'
  NeoBundle 'SirVer/ultisnips', {'depends': 'honza/vim-snippets'} "{{{
    let g:UltiSnipsSnippetsDir="~/.vim/UltiSnips"
    " Trigger configuration.
    let g:UltiSnipsExpandTrigger="<tab>"
    let g:UltiSnipsJumpForwardTrigger="<tab>"
    let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

    " If you want :UltiSnipsEdit to split your window.
    let g:UltiSnipsEditSplit="vertical"
  "}}}
"}}}

" Editing {{{
  NeoBundleLazy 'editorconfig/editorconfig-vim', {'autoload': {'insert':1}}
  NeoBundleLazy 'godlygeek/tabular', {'autoload':{'commands': 'Tabularize'}}
  NeoBundle 'tomtom/tcomment_vim'
  NeoBundle 'terryma/vim-expand-region'
  NeoBundle 'terryma/vim-multiple-cursors'

  NeoBundle 'nathanaelkane/vim-indent-guides' "{{{
  let g:indent_guides_start_level=2
  let g:indent_guides_guide_size=1
  let g:indent_guides_enable_on_vim_startup=1
  let g:indent_guides_color_change_percent=3
  if !has('gui_running')
    let g:indent_guides_auto_colors=0
    function! s:indent_set_console_colors()
      hi IndentGuidesOdd ctermbg=235
      hi IndentGuidesEven ctermbg=236
    endfunction
    autocmd VimEnter,Colorscheme * call s:indent_set_console_colors()
  endif
  "}}}
"}}}

" Colorschemes {{{
  NeoBundle 'noahfrederick/Hemisu'

  " Make gvim-only colorschemes work transparently in terminal vim
  NeoBundle 'godlygeek/csapprox'
"}}}

" Misc {{{

  " a Git wrapper so awesome, it should be illegal
  NeoBundle 'tpope/vim-fugitive'

  " Plugin to unload all buffers but the current one
  NeoBundle 'duff/vim-bufonly'

  " Unload/delete/wipe a buffer, keep its window(s), display last accessed buffer(s)
  NeoBundle 'vim-scripts/bufkill.vim' "{{{
    nmap <silent> <A-q> :BD<CR>
  "}}}

  " Vim motions on speed
  NeoBundle 'Lokaltog/vim-easymotion'

  " Multi-language DBGP debugger client for Vim (PHP, Python, Perl, Ruby, etc.)
  NeoBundle 'joonty/vdebug.git' " {{{
    let g:vdebug_options= {
      \ "port" : 9000,
      \ "server" : 'localhost',
      \ "timeout" : 20,
      \ "on_close" : 'detach',
      \ "break_on_open" : 1,
      \ "ide_key" : 'XDEBUG',
      \ "path_maps" : {},
      \ "debug_window_level" : 0,
      \ "debug_file_level" : 0,
      \ "debug_file" : "",
      \ "watch_window_style" : 'expanded',
      \ "marker_default" : '⬦',
      \ "marker_closed_tree" : '▸',
      \ "marker_open_tree" : '▾'
    \}
  "}}}

  NeoBundle 'mhinz/vim-startify' "{{{
    let g:startify_session_dir = s:get_cache_dir('sessions')
    let g:startify_change_to_vcs_root = 1
    let g:startify_show_sessions = 1
  "}}}

  NeoBundle 'scrooloose/syntastic' "{{{
    let g:syntastic_php_checkers = ['php', 'phpcs', 'phpmd']
  "}}}
"}}}

"}}}

" mappings {{{
  nnoremap <C-S-Tab> :bprev<CR>
  nnoremap <C-Tab> :bnext<CR>
  nmap <C-Insert> "+y
  vmap <C-Insert> "+y
  nmap <S-Insert> "+gp
  imap <S-Insert> <ESC>l<S-Insert>i
  map <Esc><Esc><Esc>  :qa!<CR>
  noremap <silent> <M-Right> :vertical resize +10<CR>
  noremap <silent> <M-Left>  :vertical resize -10<CR>
  noremap <silent> <M-Up>    :resize +10<CR>
  noremap <silent> <M-Down>  :resize -10<CR>
  nmap <silent> <A-C-q> :bd<CR>

  " move around splits
  map <C-l> <C-w>l
  map <C-k> <C-w>k
  map <C-j> <C-w>j
  map <C-h> <C-w>h

  " Moving your Vim cursor around using the arrow keys is a bad habit
  noremap <Up> <NOP>
  noremap <Down> <NOP>
  noremap <Left> <NOP>
  noremap <Right> <NOP>

  inoremap <Up> <NOP>
  inoremap <Down> <NOP>
  inoremap <Left> <NOP>
  inoremap <Right> <NOP>
" }}}

" commands {{{
  command! W w
" }}}

filetype plugin indent on

syntax enable

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

colorscheme hemisu

" vim: fdm=marker ts=2 sts=2 sw=2 fdl=0
