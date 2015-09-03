" Language:	Sip Index
" Maintainer:	Emrah Soytekin (emrahsoytekin@gmail.com)
" URL:		
" Last Change: 03.09.2015_08.56
"
if !has('python')
    finish
endif

if exists("b:did_ftplugin")
    finish
endif

function! s:alignFields() abort
    "set modifiable
    AddTabularPattern! sipArrow /^[^<-]*\zs[<-]/r1c0l0
    Tabularize sipArrow
    AlignCtrl lWC : :
    Align 
    set nonu
    vertical resize 25
    "w
    "set nomodifiable
endfunction

function! s:goto_win(winnr, ...) abort
    let cmd = type(a:winnr) == type(0) ? a:winnr . 'wincmd w'
                                     \ : 'wincmd ' . a:winnr
    let noauto = a:0 > 0 ? a:1 : 0

    if noauto
        noautocmd execute cmd
    else
        execute cmd
    endif
endfunction

if exists(':Tabularize')
    "call s:alignFields()
endif

function! sipindex#SwitchAndGotoLine(linePattern) abort
 if(!empty(a:linePattern))
    let currLine = split(a:linePattern,':')[1]
    execute "normal! \<C-W>\<C-H>"
    execute currLine
    execute "normal! zz"
 endif
endfunction

nmap <buffer> <silent><CR> :call sipindex#SwitchAndGotoLine(getline('.'))<CR> 
