" Language:	Sip Index
" Maintainer:	Emrah Soytekin (emrahsoytekin@gmail.com)
" URL:		
" Last Change: 03.09.2015_08.56
"
"if !has('python')
    "finish
"endif

if exists("g:loaded_sipindex_plugin")"{{{
    finish
endif"}}}

let g:loaded_sipindex_plugin = 1

function! s:alignFields() abort"{{{
    "set modifiable
    AddTabularPattern! sipArrow /^[^<-]*\zs[<-]/r1c0l0
    Tabularize sipArrow
    AlignCtrl lWC : :
    Align 
    set nonu
    vertical resize 25
    "w
    "set nomodifiable
endfunction"}}}

function! s:goto_win(winnr, ...) abort"{{{
    let cmd = type(a:winnr) == type(0) ? a:winnr . 'wincmd w'
                                     \ : 'wincmd ' . a:winnr
    let noauto = a:0 > 0 ? a:1 : 0

    if noauto"{{{
        noautocmd execute cmd
    else
        execute cmd
    endif"}}}
endfunction"}}}

if exists(':Tabularize')"{{{
    "call s:alignFields()
endif"}}}


function! sipindex#SwitchAndGotoLine() abort"{{{
 let line = getline('.')
 let messageLines = matchstr(line,'\v.*\{\zs.*\ze\}')
 if !empty(messageLines)
    let startLine = split(messageLines,",")[0]
    call s:goto_win(bufwinnr(g:current_buffer_name))
    execute startLine
    execute "normal! zt"
 endif
endfunction"}}}

function! sipindex#DeleteSipMessage() abort"{{{
    let save_cursor = getpos(".")
    let line = getline('.')
    let deleteLines = matchstr(line,'\v.*\{\zs.*\ze\}')
    if !empty(deleteLines)"{{{
        call s:goto_win(bufwinnr(g:current_buffer_name))
        execute deleteLines.'d'
        "execute 'w'
        "call s:goto_win('l')
        "call s:goto_win(bufwinnr('__sipindex__'))
        call s:goto_win(winnr('#')) " goto previous buffer
        call sipindex#ReloadIndex()
        call setpos('.', save_cursor)
    endif"}}}
endfunction"}}}

function! sipindex#CommentSipMessage() abort"{{{
    let save_cursor = getpos(".")
    let line = getline('.')
    let commentLines = matchstr(line,'\v.*\{\zs.*\ze\}')
    if !empty(commentLines)"{{{
        call s:goto_win(bufwinnr(g:current_buffer_name))
        "TODO: some task
        execute commentLines.'s/\v(^.*$)/\<!-- \1  --\>/'
        call s:goto_win(winnr('#')) " goto previous buffer
        call sipindex#ReloadIndex()
        call setpos('.', save_cursor)
    endif"}}}
endfunction"}}}

fun sipindex#UndoDeleted() abort"{{{
    let save_cursor = getpos(".") 
    call s:goto_win(bufwinnr(g:current_buffer_name))
    execute 'normal! u'
    "execute 'w'
    call s:goto_win(winnr('#')) " goto previous buffer
    call sipindex#ReloadIndex()
    call setpos('.', save_cursor)
    " code
endf"}}}

"nmap <buffer> <silent><CR> :call sipindex#SwitchAndGotoLine(getline('.'))<CR> 
"nmap <buffer> <silent><2-LeftMouse> :call sipindex#SwitchAndGotoLine(getline('.'))<CR> 
"nmap <buffer> <silent>r :call sipindex#ReloadIndex()<CR> 
