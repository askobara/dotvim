" Setup & neobundle {{{
  if has('vim_starting')
    set nocompatible               " Be iMproved

    " Required:
    set runtimepath+=~/.vim/bundle/neobundle.vim/
  endif

  let neobundle_readme=expand('~/.vim/bundle/neobundle.vim/README.md')

  if !filereadable(neobundle_readme)
    echo "Installing NeoBundle..."
    echo ""
    silent !mkdir -p ~/.vim/bundle
    silent !git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim/
  endif
"}}}

" needs for nvim
set runtimepath+=~/.vim/

let s:cache_dir = '~/.vim/.cache'
function! s:get_cache_dir(suffix) "{{{
  return resolve(expand(s:cache_dir . '/' . a:suffix))
endfunction "}}}


" number of colors in terminal
set t_Co=256

set number
set relativenumber

let mapleader = "\<Space>"

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
set timeoutlen=500
set ttimeoutlen=100
set updatetime=1000

set laststatus=2
set noruler

set foldmethod=expr

set tags=tags;/

set background=dark

set completeopt-=preview

if exists('+colorcolumn')
  set colorcolumn=80
  augroup ccolumn
    autocmd!
    autocmd WinLeave * setlocal nocursorcolumn
    autocmd WinEnter * setlocal cursorcolumn
  augroup end
endif

if has('gui_running')
  " Only show cursorline in the current window and in normal mode.
  augroup cline
    autocmd!
    autocmd WinLeave,InsertEnter * setlocal nocursorline
    autocmd WinEnter,InsertLeave * setlocal cursorline
  augroup end

  set guioptions=
  set mouse=

  set spell
  set spelllang=en_us
endif

if has('nvim')
  " set unnamedclip
  " set clipboard=unnamed
endif

augroup vimrc
  autocmd!

  " Source the vimrc file after saving it
  autocmd BufWritePost $MYVIMRC source $MYVIMRC | setlocal filetype=vim | call <SID>reload_interface()

  " Save when losing focus
  autocmd FocusLost,BufEnter * :silent! wall "| :SyntasticCheck

augroup end

" Make sure Vim returns to the same line when you reopen a file.
augroup line_return
    autocmd!
    autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \     execute 'normal! g`"zvzz' |
        \ endif
augroup end

" NeoBundle begin {{{

" Core {{{
  call neobundle#begin(expand('~/.vim/bundle/'))

  " Let NeoBundle manage NeoBundle
  NeoBundleFetch 'Shougo/neobundle.vim'

  " Extends the existing functionality of '%' key
  NeoBundleLazy 'matchit.zip', { 'autoload' : { 'mappings' : ['%', 'g%'] }} "{{{
    let bundle = neobundle#get('matchit.zip')
    function! bundle.hooks.on_post_source(bundle)
      silent! execute 'doautocmd Filetype' &filetype
    endfunction
  "}}}

  NeoBundle 'tpope/vim-surround'

  NeoBundle 'bling/vim-airline' "{{{
    let g:airline_theme = 'flatlandia'
    let g:airline_powerline_fonts = 1
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#branch#enabled = 1
    let g:airline#extensions#syntastic#enabled = 0
    let g:airline#extensions#tabline#formatter = 'unique_tail'
  "}}}

  NeoBundle 'Shougo/vimfiler.vim', {'autoload':{'commands':['VimFilerExplorer','VimFiler']}} " {{{
    let g:vimfiler_as_default_explorer = 1
    let g:vimfiler_data_directory = s:get_cache_dir('vimfiler')
    let g:vimfiler_tree_opened_icon = '▼'
    let g:vimfiler_tree_closed_icon = '▶'
    let g:vimfiler_tree_leaf_icon = ' '
    let g:vimfiler_marked_file_icon = '★'
    let g:vimfiler_readonly_file_icon = ''

    nmap <silent> <leader>t :VimFilerExplorer -buffer-name=explorer -find<CR>

    augroup vimfiler
      autocmd!
      autocmd FileType vimfiler call s:vimfiler_settings()
    augroup end

    function! s:vimfiler_settings()
      nunmap <buffer> <C-j>
      nmap <silent><buffer><expr> <Cr> vimfiler#smart_cursor_map(
            \ "\<Plug>(vimfiler_expand_tree)",
            \ "\<Plug>(vimfiler_edit_file)")
    endfunction
  "}}}

  NeoBundle 'Shougo/vimproc.vim', {'build': {'unix': 'make -f make_unix.mak'}}

  NeoBundle 'sheerun/vim-polyglot'
" }}}

" Unite {{{

  " Unite and create user interfaces
  NeoBundle 'Shougo/unite.vim' "{{{
    let g:unite_data_directory=s:get_cache_dir('unite')
    let g:unite_enable_start_insert=1
    let g:unite_source_history_yank_enable=1
    let g:unite_source_rec_max_cache_files=0
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

    nnoremap <silent> <leader>f :<C-u>Unite -auto-resize -toggle -resume -input= -buffer-name=files file_rec/async:!<CR>
    nnoremap <silent> <leader>/ :<C-u>Unite -toggle -buffer-name=search grep:.<CR>

    " Custom mappings for the unite buffer
    augroup unite
      autocmd!
      autocmd FileType unite call s:unite_settings()
    augroup end

    function! s:unite_settings()
      " Enable navigation with control-j and control-k in insert mode
      imap <buffer> <C-j> <Plug>(unite_select_next_line)
      imap <buffer> <C-k> <Plug>(unite_select_previous_line)
      nmap <buffer> <esc> <plug>(unite_exit)
      imap <buffer> <esc> <plug>(unite_exit)
    endfunction

    let g:unite_source_menu_menus = {}
    let g:unite_source_menu_menus.ftmenu = {'description': 'Fili type mune'}
    let g:unite_source_menu_menus.ftmenu.command_candidates = [
      \['phpdoc', 'call pdv#DocumentWithSnip()<CR>'],
      \['phpcs-fixer file', 'call PhpCsFixerFixFile()'],
      \['csscomb', 'CSScomb'],
      \]
    nnoremap <silent><leader>m :Unite -silent -auto-resize menu:ftmenu<CR>
  "}}}
  NeoBundle 'Shougo/tabpagebuffer.vim' "{{{
    nnoremap <silent> <leader>s :<C-u>Unite -auto-resize -toggle -buffer-name=buffers buffer_tab<cr>
  "}}}
  " Most Recently Use
  NeoBundleLazy 'Shougo/neomru.vim', {'autoload':{'unite_sources':'file_mru'}} "{{{
    nnoremap <silent> <leader>e :<C-u>Unite -auto-resize -buffer-name=recent file_mru<cr>
  "}}}

  NeoBundleLazy 'Shougo/unite-outline', {'autoload':{'unite_sources':'outline'}} "{{{
    nnoremap <silent> <leader>o :<C-u>Unite -auto-resize -buffer-name=outline outline<cr>
  "}}}
"}}}

" Autocomplete {{{
  NeoBundle 'Shougo/neocomplete.vim' "{{{
    let g:neocomplete#enable_at_startup = 1
    let g:neocomplete#disable_auto_complete=1
    let g:neocomplete#enable_smart_case = 1
    let g:neocomplete#sources#syntax#min_keyword_length = 2
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
  "}}}

  " php refactoring support for vim
  NeoBundleLazy 'vim-php/vim-php-refactoring', {'autoload': {'filetypes': 'php'}} "{{{
    let g:php_refactor_command = 'php ~/bin/refactor.phar'
  "}}}

  " Use fabpot/PHP-CS-Fixer
  NeoBundle 'stephpy/vim-php-cs-fixer', {'autoload': {'filetypes': 'php'}} "{{{
    " If php-cs-fixer is in $PATH, you don't need to define line below
    let g:php_cs_fixer_path = '~/bin/php-cs-fixer.phar' " define the path to the php-cs-fixer.phar
    let g:php_cs_fixer_level = 'psr2'                 " which level ?
    let g:php_cs_fixer_fixers_list = 'prs2,psr1,short_tag,-indentation,extra_empty_lines,-psr0' " List of fixers
    let g:php_cs_fixer_enable_default_mapping = 0     " Enable the mapping by default (<leader>pcd)
    let g:php_cs_fixer_dry_run = 0                    " Call command with dry-run option
    let g:php_cs_fixer_verbose = 0                    " Return the output of command if 1, else an inline information.
  "}}}

"}}}

" Javascript {{{
  NeoBundleLazy 'michalliu/sourcebeautify.vim', {'autoload':{
        \'filetypes':['javascript', 'html', 'css']},
        \'depends': ['michalliu/jsruntime.vim', 'michalliu/jsoncodecs.vim']
        \}

  NeoBundleLazy 'marijnh/tern_for_vim', {
        \'build': {'unix': 'npm install'},
        \'autoload':{'filetypes':['javascript']}
        \}

  NeoBundleLazy 'othree/javascript-libraries-syntax.vim', {
        \'autoload':{'filetypes':['javascript','coffee','ls','typescript']}} " {{{
    let g:used_javascript_libs = 'underscore,angularjs,jquery'
  "}}}
" }}}

" CSS {{{
  NeoBundleLazy 'csscomb/vim-csscomb', {'autoload':{'filetypes':['css'], 'commands': 'CSScomb'}}
  NeoBundleLazy 'cakebaker/scss-syntax.vim', {'autoload': {'filetypes': ['scss']}}
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
  NeoBundle 'editorconfig/editorconfig-vim'
  NeoBundleLazy 'godlygeek/tabular', {'autoload':{'commands': 'Tabularize'}}
  NeoBundle 'tomtom/tcomment_vim'
  NeoBundle 'Raimondi/delimitMate' "{{{
    let g:delimitMate_expand_cr = 1
  "}}}

  NeoBundle 'terryma/vim-multiple-cursors' "{{{
    " Avoids conflict with GoldenView
    let g:multi_cursor_use_default_mapping=0
    let g:multi_cursor_next_key='<A-j>'
    let g:multi_cursor_prev_key='<A-k>'
    let g:multi_cursor_skip_key='<A-x>'
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
      augroup indent_guides
        autocmd!
        autocmd VimEnter,Colorscheme * call s:indent_set_console_colors()
      augroup end
    endif
  "}}}
"}}}

" Motions {{{

  " Vim motions on speed
  NeoBundle 'Lokaltog/vim-easymotion'

  " Plugin to help you stop repeating the basic movement keys
  NeoBundle 'takac/vim-hardtime' "{{{
    let g:hardtime_default_on = 1
  "}}}

  " Vim plugin that provides additional text objects
  NeoBundle 'wellle/targets.vim'

  NeoBundleLazy 'AndrewRadev/sideways.vim', {'autoload': {
        \ 'commands': ['SidewaysLeft', 'SidewaysRight'],
        \ 'mappings': ['<Plug>SidewaysArgumentTextobjA', '<Plug>SidewaysArgumentTextobjI']
        \ }} "{{{

    nnoremap <c-h> :SidewaysLeft<cr>
    nnoremap <c-l> :SidewaysRight<cr>

    omap aa <Plug>SidewaysArgumentTextobjA
    xmap aa <Plug>SidewaysArgumentTextobjA
    omap ia <Plug>SidewaysArgumentTextobjI
    xmap ia <Plug>SidewaysArgumentTextobjI
  "}}}
" }}}

" Colorschemes {{{
  NeoBundle 'noahfrederick/Hemisu'
  NeoBundle 'jordwalke/flatlandia'
  NeoBundle 'whatyouhide/vim-gotham'
  NeoBundle 'altercation/vim-colors-solarized.git'
  NeoBundle 'chriskempson/base16-vim'

  " Make gvim-only colorschemes work transparently in terminal vim
  NeoBundle 'godlygeek/csapprox'
"}}}

" Misc {{{

  " Plugin to unload all buffers but the current one
  NeoBundleLazy 'duff/vim-bufonly', {'autoload': {'commands': 'BufOnly'}}

  " Unload/delete/wipe a buffer, keep its window(s), display last accessed buffer(s)
  NeoBundle 'vim-scripts/bufkill.vim' "{{{
    nmap <silent> <leader>q :BD<CR>
  "}}}

  NeoBundleLazy 'mattn/emmet-vim', {'autoload':{'filetypes':['html','xml','xsl','xslt','xsd','css','sass','scss','less','mustache']}}

  " Always have a nice view for vim split windows
  NeoBundle 'zhaocai/GoldenView.Vim' "{{{
    let g:goldenview__enable_default_mapping = 0

    " nmap <silent> <C-w>s <Plug>GoldenViewSplit
    nmap <silent> <C-j> <Plug>GoldenViewNext
    nmap <silent> <C-k> <Plug>GoldenViewPrevious
  "}}}

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
    let g:startify_bookmarks = [ '~/.vimrc' ]
  "}}}

  NeoBundle 'scrooloose/syntastic' "{{{
    let g:syntastic_php_checkers = ['php', 'phpcs', 'phpmd']
    let g:syntastic_javascript_checkers = ['jshint']
    let g:syntastic_html_checkers = ['tidy']
    let g:syntastic_html_tidy_ignore_errors=[" proprietary attribute \"ng-", " proprietary attribute \"md-"]

    let g:syntastic_error_symbol = '☠'
    let g:syntastic_warning_symbol = '⚠'
    let g:syntastic_style_error_symbol = '❗'
    let g:syntastic_style_warning_symbol = '❗'

    let g:syntastic_quiet_messages = { "type": "style" }

    if exists('g:syntastic_extra_filetypes')
      call add(g:syntastic_extra_filetypes, 'rust')
    else
      let g:syntastic_extra_filetypes = ['rust']
    endif
  "}}}

  NeoBundle 'powerman/vim-plugin-viewdoc'
"}}}

  call neobundle#end()
  filetype plugin indent on

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

    function! s:is_valid_buffer(bufnr) "{{{
      let bufnr = str2nr(a:bufnr)
      return bufexists(bufnr)
            \ && getbufvar(bufnr, '&modifiable')
            \ && getbufvar(bufnr, '&buflisted')
    endfunction "}}}

    function! s:sort_numerically(a, b)
      return a:a - a:b
    endfunction

    function! s:ctrl_tab_behavior(step) "{{{
      let candidates = gettabvar(tabpagenr(), 'tabpagebuffer')

      let buflist = map(
            \ filter(keys(candidates), '<SID>is_valid_buffer(v:val)'),
            \ 'str2nr(v:val)')

      if len(buflist) > 1
        let pos = index(sort(buflist, '<SID>sort_numerically'), bufnr('%'))
        if pos != -1
          let next = (pos + a:step) % len(buflist)
          execute ':buffer ' . buflist[next]
        endif
      endif
    endfunction "}}}

    function! s:reload_interface() "{{{
      :AirlineRefresh
      :AirlineToggle
      :AirlineToggle
    endfunction "}}}

    function! s:extended_cr_behavior()
      if pumvisible()
        return "\<C-Y>"
      elseif delimitMate#WithinEmptyPair()
        return "\<C-R>=delimitMate#ExpandReturn()\<CR>"
      else
        return "\<CR>"
      endif
    endfunction

    function! s:ChangeElement()
      execute "normal! vat\<esc>"
      call setpos('.', getpos("'<"))
      let restore = @"
      normal! yi>
      let attributes = substitute(@", '^[^ ]*', '', '')
      let @" = restore
      let dounmapb = 0
      if !maparg(">","c")
        let dounmapb = 1
        " Hide from AsNeeded
        exe "cn"."oremap > <CR>"
      endif
      let tag = input('<', '')
      if dounmapb
        silent! cunmap >
      endif
      let tag = substitute(tag, '>*$', '', '')
      exe "normal cst<" . tag . attributes . ">"
    endfunction

    function! s:compile_sass()
      if executable('sass')
        let output = fnameescape(expand('%'))
        echom output
        execute "!sass " . expand('%') . " " expand('%:r')
      endif
    endfunction

    function! s:set_title()
      let title = !empty(v:this_session) ? join(split(v:this_session, '/')[-1:-1]) : 'nvim'
      let &titlestring = title
      set title
    endfunction
" }}}

" Commands {{{
  command! W w
  command! Y y$
  command! -nargs=0 -range CtrlTabBehavior      :call <SID>ctrl_tab_behavior(1)
  command! -nargs=0 -range CtrlShiftTabBehavior :call <SID>ctrl_tab_behavior(-1)
  command! -nargs=0 CompileSass :call <SID>compile_sass()
  command! -nargs=0 SetTitle :call <SID>set_title()
" }}}

" Mappings {{{
  inoremap <silent> <Tab>      <C-r>=<SID>extended_tab_behavior()<cr>
  inoremap <silent> <Tab><Tab> <C-r>=<SID>double_tab_behavior()<cr>
  inoremap <expr> <CR> "\<C-R>=<SID>extended_cr_behavior()\<CR>"
  inoremap <expr> <BS> "\<C-R>=delimitMate#BS()\<CR>"
  nnoremap cse :call <SID>ChangeElement()<cr>

  nnoremap <C-Tab> :CtrlTabBehavior <CR>
  nnoremap <C-S-Tab> :CtrlShiftTabBehavior <CR>

  " select last paste in visual mode
  nnoremap <expr> gb '`[' . strpart(getregtype(), 0, 1) . '`]'

  " Don't move on *
  nnoremap * *<c-o>

  " Keep search matches in the middle of the window.
  nnoremap n nzzzv
  nnoremap N Nzzzv

  " Same when jumping around
  nnoremap g; g;zz
  nnoremap g, g,zz
  nnoremap <c-o> <c-o>zz

  vnoremap <silent> y y`]
  vnoremap <silent> p p`]
  nnoremap <silent> p p`]

  inoremap SS <C-o>S
  inoremap OO <C-o>O
  inoremap DD <C-o>dd
  inoremap UU <C-o>u

  nmap <C-Insert> "+y
  vmap <C-Insert> "+y
  nmap <S-Insert> "+gp
  imap <S-Insert> <ESC>l<S-Insert>i
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
  inoremap <Up> <NOP>
  inoremap <Down> <NOP>
  inoremap <Left> <NOP>
  inoremap <Right> <NOP>
" }}}

augroup Hooks
  autocmd!
augroup end

" autocmd Hooks BufWritePost *.scss silent! CompileSass

autocmd User Startified silent SetTitle

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

syntax enable
colorscheme hemisu

" vim: fdm=marker ts=2 sts=2 sw=2 fdl=0
