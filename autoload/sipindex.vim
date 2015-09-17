" Language:	Sip Index
" Maintainer:	Emrah Soytekin (emrahsoytekin@gmail.com)
" URL:		
" Last Change: 03.09.2015_08.56
"
autocmd BufWritePost * :silent call sipindex#Reload()
autocmd BufEnter  * :silent call sipindex#Init()
