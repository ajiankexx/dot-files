" =========================
" 基础设置
" =========================

" 使用 Vim 的增强模式，而不是兼容 vi
set nocompatible

" 开启语法高亮
syntax on

" 开启文件类型检测、插件和缩进
filetype plugin indent on

" 显示行号
set number

" 显示相对行号，方便跳转
set relativenumber

" 显示当前光标位置
set ruler

" 显示命令
set showcmd

" 高亮当前行
set cursorline

" 不自动换行显示长行
set nowrap

" 允许鼠标操作
set mouse=a


" =========================
" 缩进设置
" =========================

" Tab 显示为 4 个空格宽度
set tabstop=4

" 自动缩进时使用 4 个空格
set shiftwidth=4

" 按 Tab 时插入空格
set expandtab

" 智能缩进
set smartindent
set autoindent


" =========================
" 搜索设置
" =========================

" 搜索时忽略大小写
set ignorecase

" 如果搜索词包含大写，则区分大小写
set smartcase

" 边输入边搜索
set incsearch

" 高亮搜索结果
set hlsearch

" 按 Esc 取消搜索高亮
nnoremap <Esc> :nohlsearch<CR><Esc>


" =========================
" 编辑体验
" =========================

" 允许退格键删除缩进、换行等
set backspace=indent,eol,start

" 显示不可见字符
set list
set listchars=tab:»\ ,trail:·,extends:>,precedes:<

" 总是在底部保留 5 行空间
set scrolloff=5

" 命令行补全更友好
set wildmenu
set wildmode=longest:full,full

" 不生成 swap 文件
set noswapfile

" 不生成备份文件
set nobackup
set nowritebackup

" 开启持久化 undo
set undofile
set undodir=~/.vim/undo


" =========================
" 剪贴板设置
" =========================
" 终端版 Vim 虽然可能报告 +clipboard，但 macOS 下的 "+ 寄存器仍可能不可用。
" 使用 pbcopy/pbpaste 桥接默认的 y、d、c、p、P 操作。
if has('macunix') && executable('pbcopy') && executable('pbpaste')
  set clipboard=

  augroup system_clipboard_bridge
    autocmd!
    autocmd TextYankPost * if v:event.regname !=# '_' |
          \ call system('pbcopy', getreg(v:event.regname ==# '' ? '"' : v:event.regname)) |
          \ endif
  augroup END

  function! s:SystemClipboardPaste(command) abort
    let l:content = system('pbpaste')
    let l:type = l:content =~# "\n$" ? 'V' : 'v'
    call setreg('"', l:content, l:type)
    return a:command
  endfunction

  nnoremap <expr> p <SID>SystemClipboardPaste('p')
  nnoremap <expr> P <SID>SystemClipboardPaste('P')
  xnoremap <expr> p <SID>SystemClipboardPaste('"_dP')
  xnoremap <expr> P <SID>SystemClipboardPaste('"_dP')
else
  set clipboard^=unnamedplus
endif


" =========================
" 颜色与光标
" =========================

" 开启真彩色，如果终端支持
set termguicolors

" 设置配色方案
colorscheme desert

" 光标所在行加粗/高亮
highlight CursorLine cterm=bold gui=bold

" 光标列可选：如果你喜欢十字定位，可以取消下一行注释
" set cursorcolumn

" 设置不同模式下的光标形状
" 普通模式：块状光标
" 插入模式：竖线光标
" 替换模式：下划线光标
if &term =~ "xterm\\|screen\\|tmux"
  let &t_SI = "\e[6 q"
  let &t_EI = "\e[2 q"
  let &t_SR = "\e[4 q"
endif
