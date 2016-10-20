" Vim syntax file
" Language:	Sip Index
" Maintainer:	Emrah Soytekin 
" URL:		
" Last Change: (13 Aug 2015 23:03)
"

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif


syn case ignore

syntax keyword sipKeyword recv send pause action send_http recv_http send_ws recv_ws
syntax match   sipDirection  "\v\-"
syntax match   sipDirection  "\v\<"
syntax match   sipDirection  "\v\>"
syn    match   sipWhiteSpaceBeforeNumber     "\v:\s+"
"syn    match   sipLine       "\v:\s+\d+" contains=sipWhiteSpaceBeforeNumber
syn    match   sipLine       "\v:\s+\{.*\}" contains=sipWhiteSpaceBeforeNumber
syn    match   sipString     "\v\w+.*" contains=sipLine
syn    match   sipComment    "\v^\".*"


syn sync fromstart

"highlighting for SipIndex groups
highlight link sipKeyword Keyword
highlight link sipDirection Character
highlight link sipLine  Ignore "Identifier
highlight link sipWhiteSpaceBeforeNumber Ignore "Identifier
highlight link sipString String
highlight link sipComment Comment

let b:current_syntax = "sipindex"

" vim: ts=8
