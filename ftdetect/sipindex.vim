" Vim filetype detection file
" Language:	Sip Index
" Maintainer:	Emrah Soytekin (emrahsoytekin@gmail.com)
" URL:		
" Last Change: (13 Aug 2015 23:03)
"
augroup sipindex
     au! BufRead,BufNewFile *.sipindex   setfiletype sipindex
augroup END
