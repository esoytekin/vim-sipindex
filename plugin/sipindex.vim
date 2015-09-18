" Language:	Sip Index
" Maintainer:	Emrah Soytekin (emrahsoytekin@gmail.com)
" URL:		
" Last Change: 03.09.2015_08.56
function! sipindex#Init() abort
      "if (!has('python'))
        "echoerr "vim has to be compiled with python"
        "return
      "endif
      if (s:isSippFile()<0)
        echo "not sipp file"
        return
      endif
      let s:bufSipIndex = '__sipindex__'
      if( bufexists(s:bufSipIndex))
          if (bufwinnr(s:bufSipIndex) > 0 )
             call sipindex#Reload()
             return
          else
             bwipeout __sipindex__
          endif
      endif

      "call sipindex#Pyt()
      let sipArray = s:fillSipArray()
      let g:current_buffer_name = bufname('%')
      "vert belowright new "__sipindex__".bufname('%')
      vert belowright new __sipindex__
      setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nowrap foldmethod=marker filetype=sipindex
      nmap <buffer> <silent><CR> :call sipindex#SwitchAndGotoLine(getline('.'))<CR> 
      nmap <buffer> <silent><2-LeftMouse> :call sipindex#SwitchAndGotoLine(getline('.'))<CR> 
      nmap <buffer> <silent>R :call sipindex#ReloadIndex()<CR> 
      nmap <buffer> <silent>D :call sipindex#DeleteSipMessage()<CR> 
      nmap <buffer> <silent>U :call sipindex#UndoDeleted()<CR> 
      nmap <buffer> <silent>C :call sipindex#CommentSipMessage()<CR>
      "set nonu 
      "call append(0,g:arraySipIndex) 
      "unlet g:arraySipIndex
      call append(0,sipArray)
      0 
      call s:alignFields() 

      let helpText = s:getHelpText()
      call append(line('0'),helpText)
      call s:arrangeSize(getline(len(helpText)+1))
      "nmap <buffer> <silent>q :call CloseScratch()<CR>
      nmap <buffer> <silent>q :bdelete<CR>
      setlocal nomodifiable
      call s:goto_win(winnr('#'))
endfunction

" call from sipindex file"
function! sipindex#ReloadIndex() abort
    if(bufname('%')!=s:bufSipIndex)
        return
    endif
    let save_cursor = getpos(".")
    call s:goto_win(bufwinnr(g:current_buffer_name))
    call sipindex#Reload()
    call s:goto_win(winnr('#'))
    call setpos('.',save_cursor)
endfunction

function! sipindex#Reload() abort
      if (s:isSippFile()<0)
        echo "not sipp file"
        return
      endif
      if (!exists("s:bufSipIndex") ||  !bufexists(s:bufSipIndex) || bufwinnr(s:bufSipIndex) < 0 )
        return
      endif
      let g:current_buffer_name = bufname('%')
      let sipArray = s:fillSipArray()
      "call sipindex#Pyt()
      call s:goto_win(bufwinnr(s:bufSipIndex))
      setlocal modifiable
      execute "normal! ggdG"
      call append(0,sipArray) 
      "unlet g:arraySipIndex
      0 
      call s:alignFields() 
      let helpText = s:getHelpText()
      call append(line('0'),helpText)
      call s:arrangeSize(getline(len(helpText)+1))
      setlocal nomodifiable
      call s:goto_win(winnr('#'))

endfunction

function! s:pyt() abort
    let paths = substitute(escape(&runtimepath, ' '), '\(,\|$\)', '/**\1', 'g')
    let s:sipindex = fnamemodify(findfile('sipindex.py', paths), ':p')

    if !filereadable(s:sipindex)
        echohl WarningMsg
        echom 'Warning: could not find sipindex.py on your path or in your vim runtime path.'
        echohl None
        unlet s:sipindex
        return
    endif
    "python s:sipindex
    exec 'pyfile '.s:sipindex
    "python expand(s:sipindex)
    "exec '.!python '.s:sipindex
endfunc

function! s:fillSipArray() abort
    let result=[]
    let sendEnd = -1
    let actionEnd = -1
    let commentEnd = -1
    for linenum in range(0, line('$'))
        if linenum < max( [ sendEnd,actionEnd, commentEnd ] )
            continue
        endif
        let line = getline(linenum)
        
        let searchComment=matchstr(line,'\v^\s*\<\!--.*$')
        if !empty(searchComment)
            let commentEnd = s:getCommentEnd(linenum)
            continue
        endif
        let action = matchstr(line,'\v^\s*\<\zs(\w+)\ze.*\>\s*$')
        "let action = matchstr(line,"\v^\s*\<\zs(\w+)\ze.*\>\s*$")
        if !empty(action)
            if action=='send'
                let sendEnd = s:actSend(linenum,result)
            elseif action == 'recv'
                call s:actRecv(linenum,result)
            elseif action == 'pause'
                call s:actPause(linenum,result)
            elseif action == 'nop'
                let actionEnd = s:actAction(linenum,result)
            endif
        endif
    endfor
    return result
    
endfunction

" Send Recv Action Pause  functions"{{{
" send action
function! s:actSend(linenum,result) abort
    let arrowSip = "-->"
    let messageType=""
    for linej in range(a:linenum,999)
        let linejStr = getline(linej)
        let endOfMessageMultiLine = matchstr(linejStr,'\v^\s*\<\/\w+\>\s*$')
        "let endOfMessageOneLine = matchstr(linejStr,'\v^\s*\<.*\/\>\s*$')
        if !empty(endOfMessageMultiLine)
            let sendEnd=linej
            break
        endif

        if empty(messageType)
            let searchMessageTypeServer = matchstr(linejStr,'\v^\s*SIP/2\.0\s*\zs(\w+(\s+\w+)*)\ze\s*$')
            let searchMessageTypeClient = matchstr(linejStr,'\v^\s*\zs(\w+)\ze\s+sip:.*SIP\/2\.0$')
            if !empty(searchMessageTypeServer) || !empty(searchMessageTypeClient)
                let messageType = !empty(searchMessageTypeServer) ? searchMessageTypeServer : searchMessageTypeClient
            endif
        else
            let searchSDP=matchstr(linejStr,'\v^\s*o\=.*$')
            if !empty(searchSDP)
                let messageType = messageType . " (SDP)"
                "let sendEnd=linej
                "break
            endif
        endif
    endfor
    let deleteLines = '{'.a:linenum. ','.sendEnd .'}'
    call s:addToList(a:result,'send',arrowSip,messageType,a:linenum,deleteLines)
    return sendEnd

endfunction

" receive action
function! s:actRecv(linenum,result)
    let arrowSip="<--"
    let linej = getline(a:linenum)
    let searchMessageType       = matchstr(linej,'\v^\s*\<recv\s+request\=\"\zs(\w+)\ze\".*$')
    let searchMessageTypeClient = matchstr(linej,'\v^\s*\<recv\s+response\=\"\zs(\w+)\ze\".*$')
    let messageType = empty(searchMessageType) ? searchMessageTypeClient : searchMessageType
    for linej in range(a:linenum,999)
        let linejStr = getline(linej)
        let endOfMessageMultiLine = matchstr(linejStr,'\v^\s*\<\/\w+\>\s*$')
        if !empty(endOfMessageMultiLine)
            let messageEnd=linej
            break
        endif

    endfor
    let deleteLines = '{'.a:linenum. ','.messageEnd . '}'
    call s:addToList(a:result,'recv',arrowSip,messageType,a:linenum,deleteLines)
endfunction

"pause action
function! s:actPause(linenum,result)
    let line = getline(a:linenum)
    let arrowSip = "---"
    let searchMessageType=matchstr(line,'\v^\s*\<pause\s*milliseconds\=\"\zs(\d+)\ze\".*$')
    let searchMessageType = searchMessageType/1000
    let messageType = searchMessageType . ( searchMessageType > 1 ? ' seconds' : ' second' )
    call s:addToList(a:result,'pause',arrowSip,messageType,a:linenum,'{'.a:linenum.'}')
endfunction

function! s:actAction(linenum,result)
    
    let arrowSip = "---"
    for jIndex in range(a:linenum,999)
        let currentLine = getline(jIndex)

        let messageType=matchstr(currentLine,'\v^\s*\<exec\s*\zs(\w+\=\".*\")\ze.*$')
        if !empty(messageType)
            let actionEnd = jIndex
            break
        endif
    endfor
    let deleteLines = s:getDeleteLines(a:linenum,'nop')
    call s:addToList(a:result,'action',arrowSip,messageType,actionEnd,deleteLines)
    return actionEnd
endfunction"}}}

fun! s:getDeleteLines(lineStart,type)"{{{
    for linej in range(a:lineStart,999)
        let linejStr = getline(linej)
        let endOfMessageMultiLine = matchstr(linejStr,'\v^\s*\<\/\w+\>\s*$')
        if !empty(endOfMessageMultiLine) && match( endOfMessageMultiLine,a:type )>=0
            let messageEnd=linej
            break
        endif

    endfor
    
    let deleteLines = '{'.a:lineStart. ','.messageEnd .'}'
    return deleteLines
endf"}}}

fun! s:getCommentEnd(lineNr)
    for jIndex in range(a:lineNr,999)
        let line = getline(jIndex)
        let searchCommentEnd=matchstr(line,'\v^.*--\>\s*$')
        if !empty(searchCommentEnd)
            return jIndex
        endif
    endfor
endf


fun! s:addToList(list,action,arrow,msg,lineNr,deleteLines)
    call add(a:list,a:action . ' ' . a:arrow . ' ' . a:msg . ':' . a:lineNr. ':'.a:deleteLines)
endf

function! s:arrangeSize(firstLine)
    let columnPos = stridx(a:firstLine,":")
    execute "vertical resize ".( columnPos+3 )
endfunction

function! s:alignFields() abort
    if exists(':Tabularize')
        AddTabularPattern! sipArrow /^[^<-]*\zs[<-]/r1c0l0
        Tabularize sipArrow
        Tabularize /:
        0
    endif
    "set modifiable
    "AlignCtrl lWC : :
    "Align 
    "w
    "set nomodifiable
endfunction

function! s:isSippFile() abort
    if &ft!='xml'
        return -1
    endif
    for linenum in range(0, 100)
        let line = getline(linenum)
        if(match(line,"sipp.dtd")> -1)
           return 1
        endif
    endfor
    return -1
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

fun! s:getHelpText()
   let helpText = [] 
   
   call add(helpText,"\" Keyboard shortcuts{{{")
   call add(helpText,"\" <CR> -- goto line")
   call add(helpText,"\"    R -- manuanlly refresh sip_index")
   call add(helpText,"\"    D -- delete sip message")
   call add(helpText,"\"    C -- comment sip message")
   call add(helpText,"\"    U -- undo changes")
   call add(helpText,"\"    q -- quit")
   call add(helpText,"\"}}}")
   return helpText
endf

"nmap <buffer> <silent><CR> :call sipindex#Pyt()<CR> 
command! SipIndex :silent call sipindex#Init()
