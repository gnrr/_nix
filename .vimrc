"-----------------------------------------------------------
" .vimrcを保存と同時に反映させる
if has("autocmd")
  " autocmd bufwritepost .vimrc source %
endif
command! Evimrc  e $MYVIMRC

"-----------------------------------------------------------
set autoindent
set backupdir=$HOME/bak
set clipboard+=unnamed

" set paste
set expandtab
set textwidth=0
set tabstop=4
set softtabstop=4
set shiftwidth=4
set backspace=indent,eol,start
set incsearch
set ignorecase
set wildmenu
set commentstring=\ #\ %s
set foldlevel=0
syntax on

" for clipboard on tmux
"set clipboard=unnamed

"-----------------------------------------------------------
set nocompatible
filetype off
if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#rc(expand('~/.vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'Shougo/vimproc', {
      \ 'build' : {
      \     'windows' : 'make -f make_mingw32.mak',
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'unix' : 'make -f make_unix.mak',
      \    },
      \ }

NeoBundleCheck
"------------------------------------------------------------
NeoBundle 'tomasr/molokai'
NeoBundle 'sickill/vim-monokai'
"NeoBundle 'lsdr/monokai'
NeoBundle 'scrooloose/nerdtree'
"NeoBundle 'w0ng/vim-hybrid'
"NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/neomru.vim'
NeoBundle 'thinca/vim-ref'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'YankRing.vim'
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'tyru/caw.vim'
NeoBundle 'kana/vim-smartinput'
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'spolu/dwm.vim'
NeoBundle 'tpope/vim-rails'
NeoBundle 'grep.vim'
NeoBundle 'Townk/vim-autoclose'
NeoBundle 'AndrewRadev/switch.vim'

"------------------------------------------------------------
filetype plugin indent on     " required!

set background=dark
let g:rehash256 = 1
colorscheme molokai
" colorscheme solarized

set directory=$HOME/bak     " スワップファイル用のディレクトリを指定する
set hidden                  " 変更中のファイルでも、保存しないで他のファイルを表示する
set number                  " 行番号を表示する
set showmatch               " 閉括弧が入力された時、対応する括弧を強調する
set smartcase               " 検索時に大文字を含んでいたら大/小を区別
set incsearch
set wrapscan                " 検索がファイル末尾まで進んだら、ファイル先頭から再び検索する
set nowrap                  " 折り返ししない
set smarttab                " 新しい行を作った時に高度な自動インデントを行う
set cursorline
if 'gui_macvim'
    "set imdisable          " 挿入モードから抜ける際、入る際に必ずIMEがオフになる
    set antialias
    set guifont
endif

" grep検索を設定する
set grepformat=%f:%l:%m,%f:%l%m,%f\ \ %l%m,%f
set grepprg=grep\ -nh

" 検索結果のハイライトをEsc連打でクリアする
nnoremap <ESC><ESC> :nohlsearch<CR>

" カレントウィンドウにのみ罫線を引く
" set cursorline
" augroup cch
" autocmd! cch
" autocmd WinLeave * set nocursorline
" autocmd WinEnter,BufRead * set cursorline
" augroup END
" :hi clear CursorLine
" :hi CursorLine gui=underline
" highlight CursorLine ctermbg=black guibg=black
"
" : --> ;
"noremap ; :
"noremap : ;

" $ --> 4
"noremap $ 4
"noremap 4 $

" P --> p
" noremap P p
" noremap p P

" Spaceキーで画面スクロール
nnoremap <SPACE>   <PageDown>
nnoremap <S-SPACE> <PageUp>


"ビジュアルモード時vで行末まで選択
vnoremap v $h

" カレントディレクトリを自動的に移動
augroup BufferAu
    autocmd!
    autocmd BufNewFile,BufRead,BufEnter * if isdirectory(expand("%:p:h")) && bufname("%") !~ "NERD_tree" | cd %:p:h | endif
augroup END

"強制全保存終了を無効化。
nnoremap ZZ <Nop>

" ウィンドウ分割で上や左にではなく右や下に開くように
set splitright
set splitbelow

" >や<をshiftwidthの倍数倍に丸めるようにする
set shiftround

" カンマ(,)の後に自動的にスペースを入れる
inoremap , ,<Space>

" カーソル移動を物理行でなくレイアウト行で
" 物理行で移動するにはC-pやC-nで
nnoremap j gj
nnoremap k gk
nnoremap <Up> gk
nnoremap <Down> gj

" Hで行頭、Lで行末へ
" ノーマルモード、ビジュアルモード、演算待モードで有効
map H 0
map L $

" vvで行単位選択ビジュアルモードに入る。元のVが打ちづらかったので
nnoremap vv V

" 検索結果を画面中央に表示するようにする
noremap n nzz
noremap N Nzz
noremap * *zz
noremap # #zz

" x, Xで削除した文字はレジスタに突っ込ませないようにする
nnoremap x "_x
nnoremap X "_X
" YankRingでも同じように
let g:yankring_n_keys = 'Y D'

" <C-hjkl>でウィンドウ移動
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" <ESC>と誤爆しやすい<F1>でヘルプが表示されないように
inoremap <F1> <Nop>
nnoremap <F1> <Nop>

" *.mdなファイルのfiletypeををmodula2ではなくmarkdownとする
autocmd BufNewFile,BufRead *.md setfiletype markdown

" YankRing.vim
let g:yankring_history_dir = $HOME.'/.vim/'
let g:yankring_history_file = '.yankring_history'

" jellybeans
" 背景色を濃い灰色ではなく黒にする
let g:jellybeans_background_color_256 = 0
let g:jellybeans_background_color = "000000"

" Unite
" call unite#custom_default_action('file', 'tabopen')
let g:neomru#file_mru_path=expand('~/.vim/etc/neomru/file')
let g:neomru#directory_mru_path=expand('~/.vim/etc/neomru/directory')
" let g:unite_enable_start_insert=1
let g:unite_source_history_yank_enable =1
let g:unite_source_file_mru_limit = 200
" nnoremap <silent> ,uu :<C-u>Unite file_mru buffer -hide-source-names<CR>

noremap zp :Unite buffer_tab file_mru -hide-source-names<CR>
noremap zn :UniteWithBufferDir -buffer-name=files file file/new<CR>
nnoremap <leader>m :<C-u>Unite file_mru<CR>
" dwm.vim 設定（全てデフォルト）
nnoremap <c-j> <c-w>w
nnoremap <c-k> <c-w>W
nmap <m-r> <Plug>DWMRotateCounterclockwise
nmap <m-t> <Plug>DWMRotateClockwise
nmap <c-n> <Plug>DWMNew
nmap <c-c> <Plug>DWMClose
nmap <c-@> <Plug>DWMFocus
nmap <c-Space> <Plug>DWMFocus
nmap <c-l> <Plug>DWMGrowMaster
nmap <c-h> <Plug>DWMShrinkMaster

nnoremap <leader>r :<C-u>Unite file_mru<CR>

" Lokaltog/vim-easymotion
" http://blog.remora.cx/2012/08/vim-easymotion.html
" ホームポジションに近いキーを使う
let g:EasyMotion_keys='hjklasdfgyuiopqwertnmzxcvbHJKLASDFGYUIOPQWERTNMZXCVB'
" 「;」 + 何かにマッピング
let g:EasyMotion_leader_key=";"
" 1 ストローク選択を優先する
let g:EasyMotion_grouping=1
" カラー設定変更
hi EasyMotionTarget ctermbg=none ctermfg=red
hi EasyMotionShade  ctermbg=none ctermfg=blue

" comment out toggle --> \c
nmap <Leader>c <Plug>(caw:i:toggle)
vmap <Leader>c <Plug>(caw:i:toggle)

nmap <c-;> <Plug>(caw:i:toggle)
vmap <c-;> <Plug>(caw:i:toggle)


" 保存時に行末の空白を除去する
autocmd BufWritePre * :%s/\s\+$//ge
" 保存時にtabをスペースに変換する
"autocmd BufWritePre * :%s/\t/ /ge

" 日本語入力をリセット
" au BufNewFile,BufRead * set iminsert=0

" autocomplcache
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : ''
    \ }

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplcache#undo_completion()
inoremap <expr><C-l>     neocomplcache#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplcache#smart_close_popup() . "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplcache#close_popup()
inoremap <expr><C-e>  neocomplcache#cancel_popup()



" lightline setting
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'fugitive', 'filename' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'MyFugitive',
      \   'readonly': 'MyReadonly',
      \   'modified': 'MyModified',
      \   'filename': 'MyFilename'
      \ },
      \ 'separator': { 'left': '⮀', 'right': '⮂' },
      \ 'subseparator': { 'left': '⮁', 'right': '⮃' }
      \ }

function! MyModified()
  if &filetype == "help"
    return ""
  elseif &modified
    return "+"
  elseif &modifiable
    return ""
  else
    return ""
  endif
endfunction

function! MyReadonly()
  if &filetype == "help"
    return ""
  elseif &readonly
    return "⭤"
  else
    return ""
  endif
endfunction

function! MyFugitive()
  if exists("*fugitive#head")
    let _ = fugitive#head()
    return strlen(_) ? '⭠ '._ : ''
  endif
  return ''
endfunction

function! MyFilename()
  return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
       \ ('' != expand('%:t') ? expand('%:t') : '[No Name]') .
       \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

" exit from insert-mode
inoremap <silent> jj <ESC>

" end of line
noremap 4 $

" parens or bracket
inoremap { {}<Left>
inoremap [ []<Left>
inoremap ( ()<Left>
inoremap " ""<Left>
inoremap ' ''<Left>
inoremap < <><Left>

" tab
nnoremap <F12> gt
nnoremap <F11> gT


