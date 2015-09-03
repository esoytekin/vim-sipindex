" Language:	Sip Index
" Maintainer:	Emrah Soytekin (emrahsoytekin@gmail.com)
" URL:		
" Last Change: 03.09.2015_08.56
function! sipindex#Init() abort
      let bufSipIndex = '__sipindex__'
      if (s:isSippFile()<0)
        echo "not sipp file"
        return
      endif
      if( bufexists(bufSipIndex))
          if (bufwinnr(bufSipIndex) > 0 )
             call sipindex#Reload()
             return
          else
             bdelete __sipindex__
          endif
      endif

      call sipindex#Pyt()
      vert belowright new
      set modifiable
      setlocal buftype=nofile bufhidden=hide noswapfile 
      file __sipindex__
      set nonu 
      call append(0,g:arraySipIndex) 
      unlet g:arraySipIndex
      0 
      execute "setlocal filetype=sipindex"
      if exists(':Tabularize') 
          call s:alignFields() 
          0
      endif
      call s:arrangeSize(getline(1))
      nmap <buffer> <silent>q :call CloseScratch()<CR>
      set nomodifiable
endfunction

function! sipindex#Reload() abort
        let bufSipIndex = '__sipindex__'
      if (s:isSippFile()<0)
      if (s:isSippFile()<0)
        echo "not sipp file"
        return
      endif
      if ( !bufexists(bufSipIndex) || bufwinnr(bufSipIndex) < 0 )
        return
      endif
      if(&ft!='xml')
         return
      endif
      call sipindex#Pyt()
      execute "normal! \<C-W>\<C-L>"
      set modifiable
      execute "normal! ggdG"
      call append(0,g:arraySipIndex) 
      unlet g:arraySipIndex
      0 
      if exists(':Tabularize') 
          call s:alignFields() 
          0
      endif
      call s:arrangeSize(getline(1))
      set nomodifiable
      execute "normal! \<C-W>\<C-H>"


endfunction

function! sipindex#Pyt() abort
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

function! s:arrangeSize(firstLine)
    let columnPos = stridx(a:firstLine,":")
    execute "vertical resize ".columnPos
      
endfunction

function! s:alignFields() abort
    "set modifiable
    AddTabularPattern! sipArrow /^[^<-]*\zs[<-]/r1c0l0
    Tabularize sipArrow
    AlignCtrl lWC : :
    Align 
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

"nmap <buffer> <silent><CR> :call sipindex#Pyt()<CR> 
command! SipIndex :silent call sipindex#Init()
