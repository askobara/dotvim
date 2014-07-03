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
augroup vimrc
  autocmd!
  autocmd bufwritepost .vimrc source $MYVIMRC | setlocal filetype=vim
augroup end

" number of colors in terminal
set t_Co=256

set number
set relativenumber

set foldmethod=marker

" Allow backspacing everything in insert mode
set backspace=indent,eol,start

" Tabs and indent
set autoindent
set smartindent
set shiftwidth=4
set tabstop=4
set expandtab

set nowrap
set hidden

" searching
set hlsearch
set incsearch
set smartcase
if executable('ack')
  set grepprg=ack\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow\ $*
  set grepformat=%f:%l:%c:%m
endif
if executable('ag')
  set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
  set grepformat=%f:%l:%c:%m
endif

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

set lazyredraw
set ttyfast

set ttimeout
set timeoutlen=300
set ttimeoutlen=100

set laststatus=2
set noruler

set tags=tags;/

set background=dark

set completeopt-=preview

if exists('+colorcolumn')
  set colorcolumn=80
  autocmd WinLeave * setlocal nocursorcolumn
  autocmd WinEnter * setlocal cursorcolumn
endif

if has('gui_running')
  set cursorline
  autocmd WinLeave * setlocal nocursorline
  autocmd WinEnter * setlocal cursorline
  set guioptions=
  set mouse=

  set spell
  set spelllang=en_us
endif

" NeoBundle begin {{{

" Core {{{
  " Extends the existing functionality of '%' key
  NeoBundle 'matchit.zip'
  NeoBundle 'tpope/vim-surround'

  NeoBundle 'bling/vim-airline' "{{{
    let g:airline_theme = 'flatlandia'
    let g:airline_powerline_fonts = 1
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#syntastic#enabled = 1
    let g:airline#extensions#branch#enabled = 1
  "}}}

  NeoBundle 'Shougo/vimfiler.vim', {'autoload':{'commands':['VimFilerExplorer','VimFiler']}} " {{{
    let g:vimfiler_as_default_explorer = 1
    " Disable netrw.vim
    let g:loaded_netrwPlugin = 1
    let g:vimfiler_data_directory = s:get_cache_dir('vimfiler')
    let g:vimfiler_tree_opened_icon = '▼'
    let g:vimfiler_tree_closed_icon = '▶'
    let g:vimfiler_tree_leaf_icon = ' '
    let g:vimfiler_marked_file_icon = '★'
    let g:vimfiler_readonly_file_icon = ''

    nmap <silent> <A-f> :VimFilerExplorer -find<CR>
    autocmd FileType vimfiler
          \ nmap <silent><buffer><expr> <Cr> vimfiler#smart_cursor_map(
          \ "\<Plug>(vimfiler_expand_tree)",
          \ "\<Plug>(vimfiler_edit_file)")
  "}}}

  NeoBundle 'Shougo/vimproc.vim', {'build': {'unix': 'make -f make_unix.mak'}}
" }}}

" Unite {{{

  " Unite and create user interfaces
  NeoBundle 'Shougo/unite.vim' "{{{
    let g:unite_data_directory=s:get_cache_dir('unite')
    let g:unite_enable_start_insert=1
    let g:unite_source_history_yank_enable=1
    let g:unite_source_rec_max_cache_files=10000
    let g:unite_prompt='» '

    if executable('ag')
      let g:unite_source_grep_command='ag'
      let g:unite_source_grep_default_opts='--nocolor --nogroup -S -C4'
      let g:unite_source_grep_recursive_opt=''
    elseif executable('ack')
      let g:unite_source_grep_command='ack'
      let g:unite_source_grep_default_opts='--no-heading --no-color -C4'
      let g:unite_source_grep_recursive_opt=''
    endif

    nmap <space> [unite]
    nnoremap [unite] <nop>

    nnoremap <silent> [unite]f :<C-u>Unite -auto-resize -toggle -buffer-name=files file_rec/async:!<cr>
    nnoremap <silent> [unite]y :<C-u>Unite -buffer-name=yanks history/yank<cr>
    nnoremap <silent> [unite]/ :<C-u>Unite -toggle -buffer-name=search grep:.<cr>
    nnoremap <silent> [unite]s :<C-u>Unite -auto-resize -toggle -buffer-name=buffers buffer_tab<cr>
    " Custom mappings for the unite buffer
    autocmd FileType unite call s:unite_settings()
    function! s:unite_settings()
      " Enable navigation with control-j and control-k in insert mode
      imap <buffer> <C-j> <Plug>(unite_select_next_line)
      imap <buffer> <C-k> <Plug>(unite_select_previous_line)
      nmap <buffer> <esc> <plug>(unite_exit)
      imap <buffer> <esc> <plug>(unite_exit)
    endfunction
  "}}}
  " Most Recently Use
  NeoBundleLazy 'Shougo/neomru.vim', {'autoload':{'unite_sources':'file_mru'}} "{{{
    nnoremap <silent> [unite]e :<C-u>Unite -auto-resize -buffer-name=recent file_mru<cr>
  "}}}

  NeoBundleLazy 'Shougo/unite-outline', {'autoload':{'unite_sources':'outline'}} "{{{
    nnoremap <silent> [unite]o :<C-u>Unite -auto-resize -buffer-name=outline outline<cr>
  "}}}
"}}}

" Autocomplete {{{
  NeoBundle 'Shougo/neocomplete.vim' "{{{
    let g:neocomplete#enable_at_startup = 1
    let g:neocomplete#disable_auto_complete=1
    let g:neocomplete#enable_smart_case = 1
    let g:neocomplete#sources#syntax#min_keyword_length = 3
    let g:neocomplete#data_directory=s:get_cache_dir('neocomplete')

    " <CR>: insert candidate and close neocomplete popup menu
    inoremap <expr><CR> pumvisible() ? neocomplete#close_popup() : "\<CR>"

    " <BS>: close popup and delete backword char.
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
  "}}}
" }}}

" PHP {{{

  " php documentor for vim - generates php docblocks
  NeoBundleLazy 'tobyS/pdv', {'depends': 'tobyS/vmustache', 'autoload': {'filetypes': 'php'}} "{{{
    let g:pdv_template_dir = $HOME."/.vim/bundle/pdv/templates_snip"
    nnoremap <leader><leader>p :call pdv#DocumentWithSnip()<CR>
  "}}}

  " php refactoring support for vim
  NeoBundleLazy 'vim-php/vim-php-refactoring', {'autoload': {'filetypes': 'php'}} "{{{
    let g:php_refactor_command = 'php ~/bin/refactor.phar'
  "}}}

  NeoBundleLazy 'shawncplus/phpcomplete.vim', {'autoload': {'filetypes': 'php'}} "{{{
    if !exists('g:neocomplete#sources#omni#input_patterns')
      let g:neocomplete#sources#omni#input_patterns = {}
    endif
    let g:neocomplete#sources#omni#input_patterns.php =
        \ '\h\w*\|[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
  "}}}

"}}}

" Javascript {{{
  NeoBundleLazy 'pangloss/vim-javascript', {'autoload':{'filetypes':['javascript']}}
  NeoBundleLazy 'michalliu/sourcebeautify.vim', {'autoload':{'filetypes':['javascript', 'html', 'css']}, 'depends': ['michalliu/jsruntime.vim', 'michalliu/jsoncodecs.vim']}

  " Syntax highlighting for JSON in Vim
  NeoBundleLazy 'leshill/vim-json', {'autoload':{'filetypes':['javascript','json']}}
  NeoBundleLazy 'othree/javascript-libraries-syntax.vim', {'autoload':{'filetypes':['javascript','coffee','ls','typescript']}} " {{{
    let g:used_javascript_libs = 'underscore,angularjs,jquery'
  "}}}
" }}}

" HTML/CSS {{{
  NeoBundleLazy 'vim-scripts/indenthtml.vim', {'autoload': {'filetypes': ['html']}}
  NeoBundleLazy 'gorodinskiy/vim-coloresque.git', {'autoload': {'filetypes': ['html', 'css', 'less', 'sass']}}
" }}}

" Git {{{
  " a Git wrapper so awesome, it should be illegal
  NeoBundle 'tpope/vim-fugitive', {'depends': 'tpope/vim-git'}

  NeoBundleLazy 'idanarye/vim-merginal', {'autoload':{'commands': 'Merginal'}, 'depends': 'tpope/vim-fugitive'}
" }}}

" Snippets {{{
  NeoBundle 'SirVer/ultisnips', {'depends': 'honza/vim-snippets'} "{{{
    let g:UltiSnipsSnippetsDir="~/.vim/UltiSnips"
    " Trigger configuration.
    let g:UltiSnipsExpandTrigger="<F30>"
    let g:UltiSnipsJumpForwardTrigger="<F30>"
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
  NeoBundle 'terryma/vim-multiple-cursors' "{{{
    " Avoids conflict with GoldenView
    let g:multi_cursor_use_default_mapping=0
    let g:multi_cursor_next_key='<C-j>'
    let g:multi_cursor_prev_key='<C-k>'
    let g:multi_cursor_skip_key='<C-x>'
    let g:multi_cursor_quit_key='<Esc>'
  "}}}

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
  NeoBundle 'jordwalke/flatlandia'

  " Make gvim-only colorschemes work transparently in terminal vim
  NeoBundle 'godlygeek/csapprox'
"}}}

" Misc {{{

  " Plugin to unload all buffers but the current one
  NeoBundle 'duff/vim-bufonly'

  " Unload/delete/wipe a buffer, keep its window(s), display last accessed buffer(s)
  NeoBundle 'vim-scripts/bufkill.vim' "{{{
    nmap <silent> <A-q> :BD<CR>
  "}}}

  " Vim motions on speed
  NeoBundle 'Lokaltog/vim-easymotion'

  NeoBundleLazy 'mattn/emmet-vim', {'autoload':{'filetypes':['html','xml','xsl','xslt','xsd','css','sass','scss','less','mustache']}}

  NeoBundleLazy 'tpope/vim-markdown', {'autoload':{'filetypes':['markdown']}}

  " Always have a nice view for vim split windows
  NeoBundle 'zhaocai/GoldenView.Vim'

  " Multi-language DBGP debugger client for Vim (PHP, Python, Perl, Ruby, etc.)
  NeoBundle 'joonty/vdebug.git' " {{{
    if !exists('g:vdebug_options')
      let g:vdebug_options = {}
    endif
    let g:vdebug_options["ide_key"] = 'XDEBUG'
  "}}}

  NeoBundle 'mhinz/vim-startify' "{{{
    let g:startify_session_dir = s:get_cache_dir('sessions')
    let g:startify_change_to_vcs_root = 1
    let g:startify_show_sessions = 1
  "}}}

  NeoBundle 'scrooloose/syntastic' "{{{
    let g:syntastic_php_checkers = ['php', 'phpcs', 'phpmd']
    let g:syntastic_javascript_checkers = ['jshint']
    let g:syntastic_html_checkers = ['tidy']
  "}}}
"}}}

"}}}

" Functions {{{
    function! s:check_back_space() "{{{
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~ '\s'
    endfunction "}}}

    function! s:extended_tab_behavior() "{{{
      if pumvisible()
        return "\<C-n>"
      else
        call UltiSnips#ExpandSnippetOrJump()
        if g:ulti_expand_or_jump_res == 0 " || <SID>check_back_space()
          return "\<Tab>"
        endif
      endif
      return ""
    endfunction "}}}

    function! s:double_tab_behavior() "{{{
      if pumvisible()
        return "\<C-n>"
      elseif <SID>check_back_space()
        return "\<Tab>\<Tab>"
      else
        return neocomplete#start_manual_complete()
    endfunction "}}}
" }}}

" Mappings {{{
  inoremap <silent> <Tab>      <C-r>=<SID>extended_tab_behavior()<cr>
  inoremap <silent> <Tab><Tab> <C-r>=<SID>double_tab_behavior()<cr>

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

  " Moving your Vim cursor around using the arrow keys is a bad habit
  noremap <Up> <NOP>
  noremap <Down> <NOP>
  noremap <Left> <NOP>
  noremap <Right> <NOP>
" }}}

" Commands {{{
  command! W w
" }}}

filetype plugin indent on

syntax enable

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

colorscheme hemisu

" vim: fdm=marker ts=2 sts=2 sw=2 fdl=0
